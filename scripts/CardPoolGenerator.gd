extends Node
class_name CardPoolGenerator

static func generate_pool_for_data(
	unit_data: UnitData,
	draw_type: DrawSchedule.DrawType,
	count: int) -> Array[LevelupCardData]:
		
		match draw_type:
			DrawSchedule.DrawType.PASSIVE_SKILL:
				return _generate_skill_cards_for_data(unit_data, false, count)
			DrawSchedule.DrawType.ACTIVE_SKILL:
				return _generate_skill_cards_for_data(unit_data, true, count)
			DrawSchedule.DrawType.STAT_BONUS:
				return _generate_stat_cards_from_weights(unit_data, count)
		return []

static func _generate_skill_cards_for_data(
		unit_data: UnitData,
		active: bool,
		count: int) -> Array[LevelupCardData]:
	
	var all_skills := _load_skills(active)
	var owned := unit_data.skill_list
	# skip prerequisite check for UnitData — no live unit to check against
	var eligible := all_skills.filter(func(s): return s not in owned)
	eligible.shuffle()
	
	var result: Array[LevelupCardData] = []
	for i in min(count, eligible.size()):
		var card := LevelupCardData.new()
		card.card_type = LevelupCardData.CardType.ACTIVE_SKILL if active \
						 else LevelupCardData.CardType.PASSIVE_SKILL
		card.skill = eligible[i]
		card.display_name = eligible[i].name
		card.description = eligible[i].description
		card.icon = eligible[i].icon
		result.append(card)
	return result

static func _generate_stat_cards_from_weights(
		unit_data: UnitData,
		count: int) -> Array[LevelupCardData]:
	# use unit_data.attribute_weights to bias stat selection
	var weighted_stats := unit_data.attribute_weights.keys()
	weighted_stats.shuffle()
	var result: Array[LevelupCardData] = []
	for i in min(count, weighted_stats.size()):
		var card := LevelupCardData.new()
		card.card_type = LevelupCardData.CardType.STAT_BONUS
		var buff := Buff.new()
		buff.domain = Buff.Domain.UNIT
		buff.stat_index = weighted_stats[i]
		buff.buff_type = Buff.BuffType.ADD
		buff.buff_amount = 3.0
		card.stat_buff = buff
		card.display_name = "%s +3" % Stats.Attributes.keys()[weighted_stats[i]].capitalize()
		card.description = "Permanently gain 3 %s." % Stats.Attributes.keys()[weighted_stats[i]].capitalize()
		result.append(card)
	return result

static func generate_pool(
		unit: BaseUnit,
		draw_type: DrawSchedule.DrawType,
		count: int = 3) -> Array[LevelupCardData]:
	
	match draw_type:
		DrawSchedule.DrawType.PASSIVE_SKILL:
			return _generate_skill_cards(unit, false, count)
		DrawSchedule.DrawType.ACTIVE_SKILL:
			return _generate_skill_cards(unit, true, count)
		DrawSchedule.DrawType.STAT_BONUS:
			return _generate_stat_cards(unit, count)
		DrawSchedule.DrawType.CHOICE:
			# mix of types
			var pool: Array[LevelupCardData] = []
			pool.append_array(_generate_skill_cards(unit, false, 1))
			pool.append_array(_generate_skill_cards(unit, true, 1))
			pool.append_array(_generate_stat_cards(unit, 1))
			return pool
	return []

static func _generate_skill_cards(
		unit: BaseUnit,
		active: bool,
		count: int) -> Array[LevelupCardData]:
	
	# load all skills from resource folder
	var all_skills: Array[Skill] = _load_skills(active)
	
	# filter skill prerequisites and only skills not already owned
	var owned := unit.skillModule.skill_list
	var eligible := all_skills.filter(func(s):
		return s.are_prerequisites_met(unit) and s not in owned)
	
	eligible.shuffle()
	var result: Array[LevelupCardData] = []
	
	for i in min(count, eligible.size()):
		var card := LevelupCardData.new()
		card.card_type = LevelupCardData.CardType.ACTIVE_SKILL if active \
						 else LevelupCardData.CardType.PASSIVE_SKILL
		card.skill = eligible[i]
		card.display_name = eligible[i].name
		card.description = eligible[i].description
		card.icon = eligible[i].icon
		result.append(card)
	
	return result

static func _generate_stat_cards(unit: BaseUnit, count: int) -> Array[LevelupCardData]:
	var result: Array[LevelupCardData] = []
	var stats := [
		Stats.Attributes.STRENGTH, 
		Stats.Attributes.DEXTERITY,
		Stats.Attributes.ENDURANCE, 
		Stats.Attributes.INTELLECT,
		Stats.Attributes.FAITH, 
		Stats.Attributes.ATTUNEMENT
	]
	stats.shuffle()
	
	for i in min(count, stats.size()):
		var card := LevelupCardData.new()
		card.card_type = LevelupCardData.CardType.STAT_BONUS
		var buff := Buff.new()
		buff.domain = Buff.Domain.UNIT
		buff.stat_index = stats[i]
		buff.buff_type = Buff.BuffType.ADD
		buff.buff_amount = 3.0
		card.stat_buff = buff
		card.display_name = "%s +3" % Stats.Attributes.keys()[stats[i]].capitalize()
		card.description = "Permanently gain 3 %s." % Stats.Attributes.keys()[stats[i]].capitalize()
		result.append(card)
	
	return result

static func _load_skills(active: bool) -> Array[Skill]:
	var result: Array[Skill] = []
	var path := "res://ressources/Skills/ActiveSkills/" if active \
				else "res://ressources/Skills/PassiveSkills/"
	var dir := DirAccess.open(path)
	if not dir:
		return result
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.get_extension() == "tres":
			var skill := load(path + file) as Skill
			if skill :
				result.append(skill)
		file = dir.get_next()
	return result

static func generate_pool_excluding(
		unit,
		draw_type: DrawSchedule.DrawType,
		count: int,
		excluded: Array) -> Array[LevelupCardData]:
	
	# build a set of excluded skill references and names for comparison
	var excluded_skills := []
	var excluded_names := []
	for e in excluded:
		if e.skill != null:
			excluded_skills.append(e.skill)
		excluded_names.append(e.display_name)
	
	var pool: Array[LevelupCardData] = []
	if unit is BaseUnit:
		pool = generate_pool(unit, draw_type, count + excluded.size())
	elif unit is UnitData:
		pool = generate_pool_for_data(unit, draw_type, count + excluded.size())
	
	var filtered: Array[LevelupCardData] = []
	for card in pool:
		var is_excluded := false
		if card.skill != null and card.skill in excluded_skills:
			is_excluded = true
		elif card.display_name in excluded_names:
			is_excluded = true
		if not is_excluded:
			filtered.append(card)
	
	return filtered.slice(0, count)

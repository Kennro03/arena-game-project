extends Node
class_name CardPoolGenerator

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
		unit: BaseUnit,
		draw_type: DrawSchedule.DrawType,
		count: int,
		excluded: Array) -> Array[LevelupCardData]:
	# same as generate_pool but filters out already-showing cards
	var pool := generate_pool(unit, draw_type, count + excluded.size())
	return pool.filter(func(c): return c not in excluded).slice(0, count)

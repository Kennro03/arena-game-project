extends Node
class_name FighterGenerator

static func generate(
		stat_archetype: StatArchetype,
		tag_priority: Array[String],
		starting_exp: int,
		base_unit_data: humanoidUnitData) -> FighterData:
	
	var fighter := FighterData.new()
	fighter.arena_id = UIDGenerator.generate("arena_id")
	fighter.stat_archetype = stat_archetype
	fighter.tag_priority = tag_priority
	
	var data := base_unit_data._make_copy()
	data.display_name = name_registry.get_random_name("humanoid")
	
	# apply attribute weights from stat archetype
	if stat_archetype != null and not stat_archetype.stat_weights.is_empty():
		_apply_stat_archetype(data, stat_archetype)
	else:
		# for now, each attribute remains at 1, so everything has the same weight and is randomized
		pass
	
	data.stats.experience = starting_exp
	data.auto_spend_attribute_points()
	_auto_process_draws(data, tag_priority)
	
	fighter.unit_data = data
	return fighter

static func _apply_stat_archetype(data: UnitData, archetype: StatArchetype) -> void:
	var focused_attrs := archetype.stat_weights.keys()
	var total_focused_weight : float = archetype.stat_weights.values()\
		.reduce(func(a, b): return a + b, 0.0)
	
	for attr in data.attribute_weights:
		if attr in focused_attrs:
			# weight proportional to archetype definition, scaled by focus_ratio
			var relative : float = archetype.stat_weights[attr] / total_focused_weight
			data.attribute_weights[attr] = relative * archetype.focus_ratio
		else:
			# remaining ratio split equally among non-focused stats
			var non_focused_count := data.attribute_weights.size() - focused_attrs.size()
			var remaining := (1.0 - archetype.focus_ratio)
			data.attribute_weights[attr] = remaining / max(non_focused_count, 1)

static func _auto_process_draws(data: UnitData, tag_priority: Array[String]) -> void:
	while not data.stats.pending_draws.is_empty():
		var draw_type: DrawSchedule.DrawType = data.stats.pending_draws.pop_front()
		var pool := CardPoolGenerator.generate_pool_for_data(data, draw_type, 5)
		if pool.is_empty():
			continue
		
		var picked: LevelupCardData = null
		
		# walk tag priority list in order
		for tag in tag_priority:
			for card in pool:
				if tag in card.get_tags():
					picked = card
					break
			if picked:
				break
		
		# fallback to random if no tag matched
		if not picked:
			picked = pool.pick_random()
		
		data.apply_draw(picked)

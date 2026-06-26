extends SkillTargeting
class_name Targeting_NearestEnemy

@export var max_range: float = 300.0

func get_target(caster: BaseUnit) -> BaseUnit:
	return caster.get_closest_unit(
		caster.get_tree().get_nodes_in_group("Live_Units"),
		max_range,
		func(u): return not caster.check_if_ally(u))

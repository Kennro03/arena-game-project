extends Resource
class_name SkillTargeting

func get_target(_caster: BaseUnit) -> BaseUnit:
	return null

func has_targets_in_range(_caster: BaseUnit) -> bool : 
	return true

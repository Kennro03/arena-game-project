extends SkillTargeting
class_name Targeting_Self

func get_target(caster: BaseUnit) -> BaseUnit:
	return caster

func has_targets_in_range(_caster: BaseUnit) -> bool : 
	return true

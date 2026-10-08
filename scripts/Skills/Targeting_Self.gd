extends SkillTargeting
class_name Targeting_Self

func get_target(caster: Unit) -> Unit:
	return caster

func has_targets_in_range(_caster: Unit) -> bool : 
	return true

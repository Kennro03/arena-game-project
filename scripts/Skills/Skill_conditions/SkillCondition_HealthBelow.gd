extends SkillCondition
class_name SkillCondition_HealthBelow

@export var threshold_percent: float = 0.5

func is_met(unit: BaseUnit, _context: Dictionary) -> bool:
	return unit.stats.health / unit.stats.current_max_health < threshold_percent

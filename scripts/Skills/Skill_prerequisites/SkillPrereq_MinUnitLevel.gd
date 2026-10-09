extends SkillPrerequisite
class_name SkillPrereq_MinUnitLevel

@export var min_level: int = 1

func is_met(_unit: BaseUnit) -> bool:
	return _unit.stats.level >= min_level

func get_description() -> String:
	return "Level %d required" % min_level

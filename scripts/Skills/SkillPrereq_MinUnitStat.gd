extends SkillPrerequisite
class_name SkillPrereq_MinUnitStat

@export var stat: Stats.BuffableStats = Stats.BuffableStats.STRENGTH
@export var min_value: float = 10.0

func is_met(_unit: BaseUnit) -> bool:
	return _unit.stats.get_current_stat(stat) >= min_value

func get_description() -> String:
	return "%s %d required" % [Stats.BuffableStats.keys()[stat].capitalize(), min_value]

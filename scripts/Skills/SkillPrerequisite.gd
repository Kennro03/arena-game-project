extends Resource
class_name SkillPrerequisite

# returns true if the unit meets this prerequisite
func is_met(_unit: BaseUnit) -> bool:
	return true

func get_description() -> String:
	return ""

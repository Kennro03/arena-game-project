extends SkillPrerequisite
class_name Prereq_UnitHasSkill

@export var required_skill: Skill = null

func is_met(unit: Unit) -> bool:
	if required_skill == null:
		return true
	return required_skill in unit.skillModule.skill_list

func get_description() -> String:
	return "Requires: %s" % (required_skill.skill_name if required_skill else "unknown")

extends SkillPrerequisite
class_name Prereq_UnitHasSkill

@export var required_skill: Skill = null

func is_met(unit: BaseUnit) -> bool:
	if required_skill == null:
		return true
	return required_skill in unit.skill_module.skill_list

func get_description() -> String:
	return "Requires: %s" % (required_skill.skill_name if required_skill else "unknown")

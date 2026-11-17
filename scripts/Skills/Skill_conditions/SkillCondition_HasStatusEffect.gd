extends SkillCondition
class_name Condition_HasStatusEffect

@export var status_id: String = ""

func is_met(_unit: Unit, context: Dictionary) -> bool:
	var target := context.get("target") as Unit
	if target == null:
		return false
	return target.statusEffectModule.statusEffectsList.any(
		func(e): return e.status_ID == status_id)

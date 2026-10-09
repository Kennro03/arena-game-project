extends SkillCondition
class_name Condition_HasStatusEffect

@export var status_id: String = ""

func is_met(_unit: BaseUnit, context: Dictionary) -> bool:
	var target := context.get("target") as BaseUnit
	if target == null:
		return false
	return target.statusEffectModule.StatusEffects.any(
		func(e): return e.status_ID == status_id)

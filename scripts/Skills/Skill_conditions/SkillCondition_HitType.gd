extends SkillCondition
class_name SkillCondition_HitType

@export var required_damage_type: HitData.DamageType

func is_met(_unit: BaseUnit, context: Dictionary) -> bool:
	var hit := context.get("hit") as HitData
	return hit != null and hit.attack_type == required_damage_type

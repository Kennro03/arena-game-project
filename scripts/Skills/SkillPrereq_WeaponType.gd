extends SkillPrerequisite
class_name Prereq_WeaponType

@export var required_type: Weapon.WeaponTypeEnum = Weapon.WeaponTypeEnum.SWORD

func is_met(unit: BaseUnit) -> bool:
	return unit.weapon != null and unit.weapon.weaponType == required_type

func get_description() -> String:
	return "%s equipped required" % Weapon.WeaponTypeEnum.keys()[required_type].capitalize()

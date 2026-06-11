extends Resource
class_name WeaponAttackTypesDictionnary

@export var DictionnaryTitle : String = "Unarmed"
@export var DefaultAttackTypesWeights : Dictionary = {
	Weapon.AttackTypeEnum.SLASH : 0,
	Weapon.AttackTypeEnum.STAB : 0,
	Weapon.AttackTypeEnum.BASH : 0,
	Weapon.AttackTypeEnum.CAST : 0,
	Weapon.AttackTypeEnum.SHOOT : 0,
	Weapon.AttackTypeEnum.PUNCH : 1,
	}

var CurrentAttackTypesWeights : Dictionary

@export var endlags : Dictionary = {
	 Weapon.AttackTypeEnum.SLASH : 0.15,
	Weapon.AttackTypeEnum.STAB : 0.15,
	Weapon.AttackTypeEnum.BASH : 0.15,
	Weapon.AttackTypeEnum.CAST : 0,
	Weapon.AttackTypeEnum.SHOOT : 0,
	Weapon.AttackTypeEnum.PUNCH : 0.15
}

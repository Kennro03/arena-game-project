extends BaseUnit
class_name Stickman

func _init() -> void:
	pass

func _ready() -> void:
	weapon_spritesheets = {
		Weapon.WeaponTypeEnum.UNARMED: preload("res://ressources/Sprites/Units/Stickman/UnarmedStickman.png"),
		Weapon.WeaponTypeEnum.SWORD:   preload("res://ressources/Sprites/Units/Stickman/SwordStickman.png"),
		Weapon.WeaponTypeEnum.HAMMER:   preload("res://ressources/Sprites/Units/Stickman/HammerStickman.png"),
		Weapon.WeaponTypeEnum.DAGGER:   preload("res://ressources/Sprites/Units/Stickman/DaggerStickman.png"),
	}
	super._ready()

extends Resource
class_name WeaponHitboxesData

@export var hitboxes: Dictionary = {
	# Weapon.AttackStyle.SLASH: HitboxData
	# Weapon.AttackStyle.STAB: HitboxData
}

func has_hitbox_for(style: Weapon.AttackTypeEnum) -> bool:
	return hitboxes.has(style)

func get_hitbox_for(style: Weapon.AttackTypeEnum) -> HitboxData:
	return hitboxes.get(style, null)

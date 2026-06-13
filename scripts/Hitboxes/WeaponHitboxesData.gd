extends Resource
class_name WeaponHitboxesData

@export var base_hitbox: HitboxData = HitboxData.new()
@export var base_crit_hitbox: HitboxData = HitboxData.new()

var current_hitbox: HitboxData = null :
	get:
		return base_hitbox if current_hitbox == null else current_hitbox
var current_crit_hitbox: HitboxData = null :
	get:
		return base_crit_hitbox if current_crit_hitbox == null else current_crit_hitbox

extends RefCounted
class_name HitData

@export var damage : float = 0.0
@export var knockback_direction : Vector2 = Vector2(0,0)
@export var knockback_force : float = 0.0
@export var status_effects: Array[String] = [] # optional, e.g. "Burn", "Stun"

func _init(_damage_or_data = null, _dir: Vector2 = Vector2.ZERO, _force: float = 0.0, _effects: Array[String] = []):
	if typeof(_damage_or_data) == TYPE_DICTIONARY:
		var data: Dictionary = _damage_or_data
		damage = data.get("damage", 0.0)
		knockback_direction = data.get("knockback_direction", Vector2.ZERO)
		knockback_force = data.get("knockback_force", 0.0)
		status_effects = data.get("status_effects", [])
	else:
		damage = _damage_or_data if _damage_or_data != null else 0.0
		knockback_direction = _dir
		knockback_force = _force
		status_effects = _effects

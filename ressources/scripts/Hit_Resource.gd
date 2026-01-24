extends RefCounted
class_name HitData

var hit_owner : Node2D
var is_critical : bool = false
var attack_type : Weapon.AttackTypeEnum

@export var base_damage : float = 0.0
@export var crit_mult : float
@export var knockback_direction : Vector2 = Vector2(0,0)
@export var knockback_force : float = 0.0
@export var status_effects: Array[StatusEffect] = [] # optional, e.g. "Burn", "Stun"


func _init(_hit_owner : Node2D, _damage_or_data = null, _dir: Vector2 = Vector2.ZERO, _force: float = 0.0, _effects: Array[StatusEffect] = [], _is_critical: bool = false):
	if typeof(_damage_or_data) == TYPE_DICTIONARY:
		var data: Dictionary = _damage_or_data
		hit_owner = data.get("hit_owner")
		base_damage = data.get("base_damage", 0.0)
		knockback_direction = data.get("knockback_direction", Vector2.ZERO)
		knockback_force = data.get("knockback_force", 0.0)
		status_effects = data.get("status_effects", [])
		is_critical = data.get("is_critical", false)
	else:
		hit_owner = _hit_owner
		base_damage = _damage_or_data if _damage_or_data != null else 0.0
		knockback_direction = _dir
		knockback_force = _force
		status_effects = _effects
		is_critical = _is_critical

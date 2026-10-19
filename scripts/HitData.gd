extends RefCounted
class_name HitData

enum DamageType { NONE, SLASH, PIERCE, BLUNT, ETHEREAL, ORDER, ENTROPY, FIRE, FROST, LIGHTNING, EARTH, WIND }

const DAMAGE_TYPE_SPRITE_INDEX := {
	DamageType.NONE: 0,
	DamageType.SLASH: 1,
	DamageType.PIERCE: 2,
	DamageType.BLUNT: 3,
	DamageType.ETHEREAL: 4,
	DamageType.ORDER: 5,
	DamageType.ENTROPY: 6,
	DamageType.FIRE: 7,
	DamageType.FROST: 8,
	DamageType.EARTH: 9,
	DamageType.LIGHTNING: 10,
	DamageType.WIND: 11,
}

const DAMAGE_TYPE_COLOR_INDEX:= {
	DamageType.NONE: Color.WHITE,
	DamageType.SLASH: Color.WHITE,
	DamageType.PIERCE: Color.WHITE,
	DamageType.BLUNT: Color.WHITE,
	DamageType.ETHEREAL: Color.DODGER_BLUE,
	DamageType.ORDER: Color.DARK_ORANGE,
	DamageType.ENTROPY: Color.REBECCA_PURPLE,
	DamageType.FIRE: Color.FIREBRICK,
	DamageType.FROST: Color.LIGHT_BLUE,
	DamageType.EARTH: Color.SADDLE_BROWN,
	DamageType.LIGHTNING: Color.GOLD,
	DamageType.WIND: Color.LIME_GREEN,
}

var hit_owner : Unit
var is_critical : bool = false

enum HitOutcome { NONE, HIT, BLOCK, PARRY, DODGE }
var outcome : HitOutcome = HitOutcome.NONE

@export var base_damage : float = 0.0
@export var damage_type : DamageType
@export var knockback_direction : Vector2 = Vector2(0,0)
@export var knockback_force : float = 0.0
@export var status_effects: Array[StatusEffect] = [] # optional, e.g. "Burn", "Stun"
var crit_mult : float = 1.0

func _init(_hit_owner : Node2D, _damage_or_data = null, _dir: Vector2 = Vector2.ZERO, _force: float = 0.0, _effects: Array[StatusEffect] = [], _is_critical: bool = false):
	if typeof(_damage_or_data) == TYPE_DICTIONARY:
		var data: Dictionary = _damage_or_data
		hit_owner = data.get("hit_owner")
		base_damage = data.get("base_damage", 0.0)
		damage_type = data.get("damage_type",damage_type)
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

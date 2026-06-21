@tool
extends Resource
class_name Buff

enum BuffType { ADD, MULTIPLY,}
enum Domain { UNIT, WEAPON, ARMOR, PROJECTILE }

@export var domain: Domain = Domain.UNIT:
	set(value):
		domain = value
		notify_property_list_changed()  

@export var buff_type : BuffType = BuffType.ADD
@export var buff_amount: float = 0.0
@export var source: String = ""      # for display: "Iron Pip", "Ring of Strength"

@export var stat_index: int = 0 

static var stat_icons : Dictionary = {
	Weapon.BuffableStats.DAMAGE: preload("uid://br85td3jaqel7"),
	Weapon.BuffableStats.ATTACK_SPEED: preload("uid://w6i0f1b7rffo"),
	Weapon.BuffableStats.ATTACK_RANGE: preload("uid://d0tjxydbev5m4"),
	Weapon.BuffableStats.KNOCKBACK: preload("uid://brfm5e6515tqd"),
}

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	match domain:
		Domain.UNIT:
			props.append({
				"name": "stat_index",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(Stats.BuffableStats.keys()),
				})
		Domain.WEAPON:
			props.append({
				"name": "stat_index",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(Weapon.BuffableStats.keys()),
				})
		Domain.ARMOR:
			props.append({
				"name": "stat_index",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "PLACEHOLDER",  ## PLACEHOLDER UNTIL ARMOR IS SET UP
				})
		Domain.PROJECTILE:
			props.append({
				"name": "stat_index",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(Projectile.BuffableStats.keys()),
				})
	
	return props

func get_unit_stat() -> Stats.BuffableStats:
	return stat_index as Stats.BuffableStats

func get_weapon_stat() -> Weapon.BuffableStats:
	return stat_index as Weapon.BuffableStats

func get_armor_stat() -> void:
	return 

func get_projectile_stat() -> Projectile.BuffableStats:
	return stat_index as Projectile.BuffableStats

func _init( _domain : Domain = Domain.UNIT,
			_stat_index: int = 0, 
			_buff_amount: float = 0.0,
			_buff_type: Buff.BuffType = BuffType.ADD) -> void:
	domain = _domain
	stat_index = _stat_index
	buff_type = _buff_type
	buff_amount = _buff_amount

#static func random_flat_attribute_buff(min_amount: int = 1, max_amount: int = 15) -> Buff:
#	var attribute : int = Stats.Attributes.values().pick_random()
#	return Buff.new(
#		Buff.Domain.UNIT,
#		Stats.BuffableStats.values()[attribute],
#		randi_range(min_amount, max_amount),
#		Buff.BuffType.ADD
#	)

#static func random_multiplier_stat_buff(min_amount: float = 0.1, max_amount: float = 0.3) -> Buff:
#	return Buff.new(
#		Buff.Domain.UNIT,
#		Stats.BuffableStats.values().pick_random(),
#		randf_range(min_amount, max_amount),
#		Buff.BuffType.MULTIPLY
#	)

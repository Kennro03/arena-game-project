extends Item
class_name Armor

enum BuffableStats {
	SLASH_RESISTANCE,
	PIERCE_RESISTANCE,
	BLUNT_RESISTANCE,
	FIRE_RESISTANCE,
	FROST_RESISTANCE,
	LIGHTNING_RESISTANCE,
	EARTH_RESISTANCE,
	WIND_RESISTANCE,
	WATER_RESISTANCE,
	ORDER_RESISTANCE,
	ENTROPY_RESISTANCE,
}

static var resistance_to_damage_type: Dictionary = {
	BuffableStats.SLASH_RESISTANCE:     HitData.DamageType.SLASH,
	BuffableStats.PIERCE_RESISTANCE:    HitData.DamageType.PIERCE,
	BuffableStats.BLUNT_RESISTANCE:     HitData.DamageType.BLUNT,
	BuffableStats.FIRE_RESISTANCE:      HitData.DamageType.FIRE,
	BuffableStats.FROST_RESISTANCE:     HitData.DamageType.FROST,
	BuffableStats.LIGHTNING_RESISTANCE: HitData.DamageType.LIGHTNING,
	BuffableStats.EARTH_RESISTANCE:     HitData.DamageType.EARTH,
	BuffableStats.WIND_RESISTANCE:      HitData.DamageType.WIND,
	BuffableStats.WATER_RESISTANCE:     HitData.DamageType.WATER,
	BuffableStats.ORDER_RESISTANCE:     HitData.DamageType.ORDER,
	BuffableStats.ENTROPY_RESISTANCE:   HitData.DamageType.ENTROPY,
}

## Armor has resistance stats, stat boosts, and passives
@export_group("Armor data")
@export var armorIcon : Texture2D
@export var armorTexture : Texture2D
@export var armor_colorPalette : Texture2D
@export var base_resistances: Dictionary = {
	HitData.DamageType.SLASH: 1.0,
	HitData.DamageType.PIERCE: 1.0,
	HitData.DamageType.BLUNT: 1.0,
	HitData.DamageType.FIRE :1.0,
	HitData.DamageType.FROST :1.0,
	HitData.DamageType.LIGHTNING :1.0,
	HitData.DamageType.EARTH :1.0,
	HitData.DamageType.WIND :1.0,
	HitData.DamageType.WATER :1.0,
	HitData.DamageType.ORDER :1.0,
	HitData.DamageType.ENTROPY :1.0,
}

var current_resistances: Dictionary = {}

@export_subgroup("Passives")
@export var buffs : Array[Buff] = [] #Array of stat buffs applied to holder
@export var skills : Array = [] #Array of skills, usually passives, that are yet to be implemented

@export_subgroup("Pip related")
@export var pips : Array[Pip] = []
@export var guaranteed_pips_count : int = 0
@export var random_pips_amount : Vector2 = Vector2(0,0)
@export var allowed_pips_list : Array[Pip] = [] # select pips from this array, generate random pips when empty
@export var custom_pip_rarities_weigths : Dictionary = {
	Pip.Rarity.COMMON : 40.0,
	Pip.Rarity.UNCOMMON : 19.0,
	Pip.Rarity.RARE : 9.0,
	Pip.Rarity.EPIC : 4.0,
	Pip.Rarity.LEGENDARY : 1.0,
	Pip.Rarity.NEGATIVE : 6.0,
	Pip.Rarity.UNIQUE : 0.0,
}

var armor_stat_buffs : Array[Buff] = []
var owner: Node2D

func _init() -> void:
	item_type = Item.ItemType.ARMOR

func get_resistance(damage_type: HitData.DamageType) -> float:
	return current_resistances.get(damage_type, 1.0)

func setup_stats() -> void :
	if owner == null:
		printerr("No owner!")
		return
	_reset_stats()

func _reset_stats() -> void:
	current_resistances = base_resistances

func add_armor_buff(buff: Buff) -> void :
	if buff in armor_stat_buffs:
		return
	armor_stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_armor_buff(buff: Buff) -> void :
	armor_stat_buffs.erase(buff)
	recalculate_stats.call_deferred()

func clear_armor_buffs() -> void:
	armor_stat_buffs.clear()
	recalculate_stats()

func recalculate_stats() -> void:
	_reset_stats()
	
	var _stat_multipliers: Dictionary = {} #Amount to multiply stats by
	var _stat_addends: Dictionary = {} #Amount to add to included stats
	
	#Armor buffs
	for buff in armor_stat_buffs :
		pass

func apply_owner_buffs(stats: Stats):
	for buff in buffs:
		stats.add_buff(buff)

func remove_owner_buffs(stats: Stats):
	for buff in buffs:
		stats.remove_buff(buff)

func generate_pips(rarity_weights: Dictionary = custom_pip_rarities_weigths) -> void:
	pips = PipRegistry.roll_pips(self, rarity_weights)
	apply_pips()

func apply_pips() -> void:
	for pip in pips:
		if pip.buff == null:
			continue
		match pip.buff.domain:
			Buff.Domain.ARMOR:
				buffs.append(pip.buff)
			_:
				pass

func get_value() -> int:
	var value : int = base_value
	for pip in pips :
		value += pip.get_pip_value()
	#if weapon_material : 
	#	value *= int(weapon_material.value_multiplier)
	return value 

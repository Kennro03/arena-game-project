extends Item
class_name Armor

## Armor has resistance stats, stat boosts, and passives
@export_group("Armor data")
@export var armorIcon : Texture2D
@export var armorTexture : Texture2D
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

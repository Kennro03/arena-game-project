extends Item
class_name Armor

## Armor only has stat boosts and passives

enum ArmorCategoryEnum { LIGHT, MEDIUM, HEAVY }

@export_group("Armor data")
@export var armorCategory : ArmorCategoryEnum

@export_subgroup("Passives")
@export var buffs : Array[Buff] = [] #Array of stat buffs applied to holder
@export var passives : Array = [] #Array of PASSIVES that are yet to be implemented

var owner: Node2D

func _init() -> void:
	item_type = Item.ItemType.ARMOR

func setup_stats() -> void :
	if owner == null:
		printerr("No owner!")
		return

func apply_owner_buffs(stats: Stats):
	for buff in buffs:
		stats.add_buff(buff)

func remove_owner_buffs(stats: Stats):
	for buff in buffs:
		stats.remove_buff(buff)

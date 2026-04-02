extends Item
class_name Accessory

## Accessories only have stat boosts and passives

@export_subgroup("Passives")
@export var statChanges : Array[StatBuff] = [] #Array of stat buffs applied to holder
@export var passives : Array = [] #Array of PASSIVES that are yet to be implemented

var owner: Node2D

func _init() -> void:
	item_type = Item.ItemType.ACCESSORY

func setup_stats() -> void :
	if owner == null:
		printerr("No owner!")
		return

func apply_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.add_buff(buff)

func remove_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.remove_buff(buff)

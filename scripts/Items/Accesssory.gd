extends Item
class_name Accessory

## Accessories only have a list of stat boosts and passives
@export_subgroup("Passives")
@export var statChanges : Array[StatBuff] = [] #Array of stat buffs applied to holder
@export var passives : Array = [] #Array of PASSIVES that are yet to be implemented

var owner: Node2D

func _init() -> void:
	item_type = Item.ItemType.ACCESSORY

func with_attribute_buffs(nb_buffs: int = 1) -> Item:
	var result := duplicate(true)
	for i in nb_buffs:
		result.passive_buffs.append(StatBuff.random_flat_attribute_buff())
	return result

func with_stat_buffs(nb_buffs: int = 1) -> Item:
	var result := duplicate(true)
	for i in nb_buffs:
		result.passive_buffs.append(StatBuff.random_multiplier_stat_buff())
	return result

func apply_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.add_buff(buff)

func remove_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.remove_buff(buff)

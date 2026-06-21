extends Item
class_name Accessory

## Accessories only have a list of stat boosts and passives
@export_subgroup("Passives")
@export var buffs : Array[Buff] = [] #Array of guaranteed buffs applied to holder
@export var passives : Array = [] #Array of passives given to the holder, yet to be implemented

@export_subgroup("Pips")
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

var owner: BaseUnit

func _init() -> void:
	item_type = Item.ItemType.ACCESSORY

func with_attribute_buffs(nb_buffs: int = 1) -> Item:
	var result := duplicate(true)
	for i in nb_buffs:
		result.buffs.append(Buff.random_flat_attribute_buff())
	return result

func with_stat_buffs(nb_buffs: int = 1) -> Item:
	var result := duplicate(true)
	for i in nb_buffs:
		result.buffs.append(Buff.random_multiplier_stat_buff())
	return result

func apply_owner_buffs(stats: Stats):
	for buff in buffs:
		stats.add_buff(buff)

func remove_owner_buffs(stats: Stats):
	for buff in buffs:
		stats.remove_buff(buff)

func _generate_metadata() -> void :
	if item_id == "" :
		printerr("No assigned item_id !")
		item_id = UIDGenerator.generate("accessory")
	
	if item_name == "" :
		printerr("No assigned item_name !")
		item_name = "Unnamed accessory"
	
	if description == "" :
		description = "An accessory."

func generate_pips(rarity_weights: Dictionary = custom_pip_rarities_weigths) -> void:
	pips = PipRegistry.roll_pips(self, rarity_weights)
	apply_pips()

func apply_pips() -> void:
	for pip in pips:
		if pip.buff == null:
			continue
		buffs.append(pip.buff) 

func get_value() -> int:
	var value : int = base_value
	for pip in pips :
		value += pip.get_pip_value()
	return value 

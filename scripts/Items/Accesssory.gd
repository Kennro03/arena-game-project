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
@export var custom_pip_rarities_weigths : Dictionary = PipRegistry.pip_default_rarities_weigths

var owner: BaseUnit

func _init() -> void:
	item_type = Item.ItemType.ACCESSORY

func add_buffs(_new_buffs: Array[Buff]) -> Item:
	var result : Accessory = duplicate(true)
	for b in _new_buffs:
		result.buffs.append(b)
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

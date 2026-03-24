extends Resource
class_name Item

enum ItemType { WEAPON, ARMOR, ACCESSORY, CONSUMABLE, ARTIFACT, QUEST, MISC }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, CURSED }

@export_group("Item Data")
@export var item_id: String
@export var item_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var item_type: ItemType
@export var rarity: Rarity = Rarity.COMMON
@export var value: int = 0  # gold value for shops

#Used to select item border for inventory
const item_borders : Dictionary = {
	Rarity.COMMON : preload("uid://bevk6u7cdgmgw"),
	Rarity.UNCOMMON : preload("uid://6a8vcs48wg3e"),
	Rarity.RARE : preload("uid://b46bdvep7q3jl"),
	Rarity.EPIC : preload("uid://w0jbb5f3lxr3"),
	Rarity.LEGENDARY : preload("uid://fb7mkuai6jba"),
	Rarity.CURSED : preload("uid://56svy7l72gac"),
} 

func _generate_metadata() -> void :
	if item_id == "" :
		printerr("No assigned item_id !")
		item_id = UIDGenerator.generate("item")
	
	if item_name == "" :
		printerr("No assigned item_name !")
		return
	
	if description == "" :
		description = "An item."

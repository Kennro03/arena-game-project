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
	Rarity.COMMON : null,
	Rarity.UNCOMMON : null,
	Rarity.RARE : null,
	Rarity.EPIC : null,
	Rarity.LEGENDARY : null,
	Rarity.CURSED : null,
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

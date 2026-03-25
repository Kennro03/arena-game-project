extends Slot
class_name ItemSlot

@export var item: Item = null

func set_item(_item: Item) -> void:
	item = _item
	set_visuals()

func get_icon() -> Texture2D:
	return item.icon if item else null

func get_border() -> Texture2D:
	return item.item_borders[item.rarity] if item else EMPTY_BORDER

func _to_string() -> String:
	return item.item_name if item else "empty"

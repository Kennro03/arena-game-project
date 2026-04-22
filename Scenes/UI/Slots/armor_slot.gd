extends ItemSlot
class_name ArmorSlot

const empty_icon := preload("uid://d0of4bhmh0wxx")

func set_item(_item: Item) -> void:
	if _item is Armor :
		item = _item
	else :
		printerr("Armor slot, cannot assing %s !" % [_item.item_name])
	set_visuals()

func get_icon() -> Texture2D:
	return item.icon if item and item.icon else empty_icon

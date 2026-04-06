extends ItemSlot
class_name AccessorySlot

const empty_icon := preload("uid://yc1ibthk837u")

func set_item(_item: Item) -> void:
	if _item is Accessory :
		item = _item
	else :
		printerr("Armor slot, cannot assing %s !" % [_item.item_name])
	set_visuals()

func get_icon() -> Texture2D:
	return item.icon if item else empty_icon

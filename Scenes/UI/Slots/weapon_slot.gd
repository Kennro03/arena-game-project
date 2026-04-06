extends ItemSlot
class_name WeaponSlot

const empty_icon := preload("uid://br85td3jaqel7")

func set_item(_item: Item) -> void:
	if _item is Weapon :
		item = _item
	else :
		printerr("Weapon slot, cannot assing %s !" % [_item.item_name])
	set_visuals()

func get_icon() -> Texture2D:
	return item.icon if item else empty_icon

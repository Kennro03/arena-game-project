extends EventEffect
class_name EventEffect_GainItem

@export var item: Item

func apply() -> void:
	Player.add_item_to_inventory(item.duplicate(true))

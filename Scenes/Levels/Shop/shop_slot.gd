extends Slot
class_name ShopSlot

@onready var price_label: Label = %PriceLabel

@export var item: Item = null
@export var cost: int : set = _on_cost_changed

func _ready() -> void:
	cost = 69

func set_item(_item: Item) -> void:
	item = _item
	set_visuals()

func get_icon() -> Texture2D:
	return item.icon if item else null

func get_border() -> Texture2D:
	return item.item_borders[item.rarity] if item else EMPTY_BORDER

func _to_string() -> String:
	return item.item_name if item else "empty"

func _on_cost_changed(new_value:int) -> void :
	cost = new_value
	price_label.text = "%dg" % [new_value]

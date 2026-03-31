extends ItemSlot
class_name ShopSlot

@onready var price_label: Label = %PriceLabel

@export var cost: int : set = _on_cost_changed

func _ready() -> void:
	cost = 69

func _on_cost_changed(new_value:int) -> void :
	cost = new_value
	price_label.text = "%dg" % [new_value]

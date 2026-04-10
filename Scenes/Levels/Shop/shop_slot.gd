extends ItemSlot
class_name ShopSlot

@export var cost: int : set = _on_cost_changed

var inside_slot : bool = false

func _ready() -> void:
	super._ready()
	if item :
		cost = item.value

func set_item(_item: Item) -> void:
	item = _item
	set_visuals()
	if item :
		cost = item.value

func _on_cost_changed(new_value:int) -> void :
	cost = new_value
	if rich_text_label:
		rich_text_label.text = "%dg" % [new_value]

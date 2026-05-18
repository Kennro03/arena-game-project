extends Control
class_name InventorySpaceDisplay

@onready var inventory_space_display: RichTextLabel = %InventorySpaceDisplay

func _ready() -> void:
	update_display(Player.deployed_units.size())
	Events.item_added.connect(update_display)
	Events.item_removed.connect(update_display)
	

func update_display(new_value:int)->void:
	inventory_space_display.text = "Inventory space : %d/%d" % [new_value,Player.inventory_size]

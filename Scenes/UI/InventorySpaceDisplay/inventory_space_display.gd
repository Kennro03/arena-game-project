extends Control
class_name InventorySpaceDisplay

@onready var inventory_space_display: RichTextLabel = %InventorySpaceDisplay

func _ready() -> void:
	update_display()
	Events.item_added.connect(update_display.unbind(1))
	Events.item_removed.connect(update_display.unbind(1))
	

func update_display()->void:
	inventory_space_display.text = "Inventory space : %d/%d" % [Player.inventory.size(),Player.inventory_size]

extends PanelContainer
class_name Inventory

@onready var item_grid_container: GridContainer = %ItemGridContainer

const ItemSlotScene : PackedScene = preload("res://Scenes/UI/inventory/item_slot.tscn") 
var item_slots : Array[ItemSlot] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_inventory()
	create_empty_slots()
	fill_slots_with_player_inventory()
	
	Events.item_added.connect(func(_item): fill_slots_with_player_inventory())
	Events.item_removed.connect(func(_item): fill_slots_with_player_inventory())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func clear_inventory() -> void:
	for item_slot in item_grid_container.get_children() :
		item_slot.queue_free()
	item_slots.clear()

func create_empty_slots() -> void :
	var i := 0
	while i < Player.inventory_size :
		var new_slot := ItemSlotScene.instantiate()
		item_grid_container.add_child(new_slot)
		item_slots.append(new_slot)
		i += 1

func fill_slots_with_player_inventory() -> void:
	for i in Player.inventory.size():
		if i >= item_slots.size():
			printerr("More items than slots ! breaking slot filling function.")
			break
		item_slots[i].set_item(Player.inventory[i])

func _on_close_button_pressed() -> void:
	queue_free()

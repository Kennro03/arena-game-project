extends PanelContainer
class_name Reserve

@onready var unit_grid_container: GridContainer = %GridContainer

const UnitSlotScene : PackedScene = preload("res://Scenes/UI/reserve/unit_slot.tscn") 
var unit_slots : Array[UnitSlot] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_inventory()
	create_empty_slots()
	fill_slots_with_player_inventory()
	
	Events.item_added.connect(func(_item): fill_slots_with_player_inventory())
	Events.item_removed.connect(func(_item): fill_slots_with_player_inventory())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func clear_inventory() -> void:
	for unit_slot in unit_grid_container.get_children() :
		unit_slot.queue_free()
	unit_slots.clear()

func create_empty_slots() -> void :
	var i := 0
	while i < Player.reserve_size :
		var new_slot := UnitSlotScene.instantiate()
		unit_grid_container.add_child(new_slot)
		unit_slots.append(new_slot)
		i += 1

func fill_slots_with_player_inventory() -> void:
	for i in Player.reserve.size():
		if i >= unit_slots.size():
			printerr("More items than slots ! breaking slot filling function.")
			break
		unit_slots[i].set_unit(Player.reserve[i])

func print_slots() -> void :
	for slot in unit_slots :
		print(str(slot))

func _on_close_button_pressed() -> void:
	queue_free()

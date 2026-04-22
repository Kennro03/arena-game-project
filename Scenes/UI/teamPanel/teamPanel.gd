extends PanelContainer
class_name TeamPanel

@onready var unit_grid_container: GridContainer = %GridContainer

const UnitSlotScene : PackedScene = preload("uid://d3h4afwsp5p4g") 
var unit_slots : Array[UnitSlot] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_slots()
	create_empty_slots()
	fill_slots_with_player_team()
	
	Events.unit_added_to_reserve.connect(func(_item): fill_slots_with_player_team())
	Events.unit_removed_from_reserve.connect(func(_item): fill_slots_with_player_team())
	Events.unit_added_to_team.connect(func(_u): fill_slots_with_player_team())
	Events.unit_removed_from_team.connect(func(_u): fill_slots_with_player_team())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func clear_slots() -> void:
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

func fill_slots_with_player_team() -> void:
	for slot in unit_slots:
		slot.set_unit(null)
	
	for i in Player.team.size():
		if i >= unit_slots.size():
			printerr("More units than reserve slots ! breaking slot filling function.")
			break
		unit_slots[i].set_unit(Player.team[i])

func print_slots() -> void :
	for slot in unit_slots :
		print(str(slot))

func _on_close_button_pressed() -> void:
	queue_free()

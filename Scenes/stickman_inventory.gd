extends Node
signal inventory_stickman_added(unit_data : StickmanData)
signal inventory_stickman_removed()

@export var stickman_scene := preload("res://Scenes/stickman.tscn")

@export var HOTBAR_SIZE := 10
@export var autofill_test_int := 4

var inventory: Array[StickmanData] = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
var selected_unit_data: StickmanData = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory[0] = StickmanData.new()
	inventory[1] = StickmanData.new().get_scaled_stickmanData(0.5)
	inventory[2] = StickmanData.new().get_scaled_stickmanData(1.5)
	inventory[3] = StickmanData.new().get_randomized_stickmanData(0.5,1.5)
	inventory[4] = StickmanData.new().get_randomized_stickmanData(1.0,3.0)
	
	
	for slot in inventory : 
		if slot != null :
			print(slot.health)
		else :
			print("Empty slot !")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_unit_to_slot(unit_data: StickmanData, _slot: int):
	if _slot < inventory.size():
		if inventory[_slot] == null : 
			inventory[_slot] = unit_data
	else :
		inventory.append(unit_data)
	emit_signal("inventory_stickman_added",unit_data)

func remove_unit_from_slot(_slot: int):
	if _slot > 0 and _slot < inventory.size():
		if inventory[_slot] != null :
			inventory[_slot] = null
	emit_signal("inventory_stickman_removed")

func add_unit(unit_data: StickmanData):
	inventory.append(unit_data)
	emit_signal("inventory_stickman_added")
	
func remove_unit(unit_data: StickmanData):
	inventory.erase(unit_data)
	emit_signal("inventory_stickman_removed")

func get_hotbar_array(hotbar_length:int) -> Array[StickmanData] :
	var hotbar_array : Array[StickmanData]
	var i := 0
	while i < hotbar_length :
		i+=1
		hotbar_array[i] = inventory[i]
	return hotbar_array

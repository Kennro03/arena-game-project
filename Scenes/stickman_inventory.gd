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
	
	var skill_array_kick : Array[Skill]
	var kick_skill = preload("res://Scenes/Skills/Kick_Skill.tres")
	var burst_skill = preload("res://Scenes/Skills/SmallBurst_Skill.tres")
	skill_array_kick.append(kick_skill)
	skill_array_kick.append(burst_skill)
	inventory[6] = StickmanData.new().get_skilled_stickmanData(1.1, skill_array_kick)
	
	
	for i in inventory.size():
		var slot = inventory[i]
		if slot != null and slot.type != null:
			print("Slot (index) : " + str(i) + " Type = " + str(slot.type))
		else:
			pass
			#print("Slot (index) " + str(i) + " is empty or invalid!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_unit(unit_data: StickmanData, _slot: int = -1):
	if _slot != -1 && _slot < inventory.size():
		inventory[_slot] = unit_data
	else :
		inventory.append(unit_data)
	emit_signal("inventory_stickman_added",unit_data)

func free_slot(_slot: int):
	if _slot >= 0 and _slot <= inventory.size():
		inventory[_slot] = null
	
func remove_unit(unit_data: StickmanData, _slot: int = -1):
	if _slot != -1 && _slot < inventory.size():
		inventory[_slot] = null
	else : 
		inventory.erase(unit_data)
	emit_signal("inventory_stickman_removed")

func get_hotbar_array(hotbar_length:int) -> Array[StickmanData] :
	var hotbar_array : Array[StickmanData]
	var i := 0
	while i < hotbar_length :
		i+=1
		hotbar_array[i] = inventory[i]
	return hotbar_array

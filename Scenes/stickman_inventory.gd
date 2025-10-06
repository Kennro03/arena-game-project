extends Node
@export var available_units: Array[Stickman]
@export var stickman_scene := preload("res://Scenes/stickman.tscn")
@export var stickman_data = StickmanData

var selected_unit: Stickman = null
var i := 0

signal inventory_stickman_added()
signal inventory_stickman_removed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stickman_data.new()
	while i < 20 : 
		
		i+=1
	print(available_units)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_unit(_slot: int,unit_data: StickmanData):
	if _slot :
		if available_units[_slot] == null : 
			available_units[_slot] = Stickman.new()
	else :
		available_units.append(Stickman.new())
	emit_signal("inventory_stickman_added")

func remove_unit(_slot: int,unit_data: StickmanData):
	if _slot :
		if available_units[_slot] != null :
			available_units[_slot] = null
	else :
		available_units.erase(Stickman.new())
	emit_signal("inventory_stickman_removed")

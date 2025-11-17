extends Control
@export var inventory_node : Node
@export var Slot_scene = preload("res://Scenes/UI/stickman_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instantiate_hotbar_slots()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == true :
			get_tree().paused = false
			$PauseLabel.hide()
		else :
			get_tree().paused = true
			$PauseLabel.show()
	pass

func instantiate_hotbar_slots():
	var i := 0
	while %HotbarHBbox.get_children().size() < 10 and i < inventory_node.HOTBAR_SIZE :
		var new_slot = Slot_scene.instantiate()
		new_slot.stickman_data = inventory_node.inventory[i]
		new_slot.name = "Hotbar_slot_"+str(i+1)
		%HotbarHBbox.add_child(new_slot)
		new_slot.connect("stickman_selected",_on_stickman_slot_stickman_selected)
		i+=1
		pass


func _on_stickman_slot_stickman_selected(unit_data: StickmanData) -> void:
	if unit_data : 
		print(unit_data.type)
	inventory_node.selected_unit_data = unit_data


func _on_stickman_inventory_inventory_stickman_added(_unit_data) -> void:
	for slot in %HotbarHBbox.get_children() : 
		if inventory_node.inventory[slot.get_index()].stickman_data : 
			%HotbarHBbox.get_child(slot.get_index()).stickman_data = inventory_node.inventory[slot.get_index()]


func _on_stickman_inventory_inventory_stickman_removed() -> void:
	pass # Replace with function body.

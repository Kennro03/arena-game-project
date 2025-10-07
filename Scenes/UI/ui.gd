extends Control
@export var inventory_node : Node
@export var Slot_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	instantiate_hotbar_slots()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func instantiate_hotbar_slots():
	var i := 0
	while i < inventory_node.HOTBAR_SIZE :
		var new_slot = Slot_scene.instantiate()
		new_slot.stickman_data = inventory_node.inventory[i]
		new_slot.name = "Hotbar_slot_"+str(i+1)
		%HotbarHBbox.add_child(new_slot)
		i+=1
		pass


func _on_stickman_inventory_inventory_stickman_added(unit_data) -> void:
	for slot in %HotbarHBbox.get_children() : 
		if inventory_node.inventory[slot.get_index()].stickman_data : 
			%HotbarHBbox.get_child(slot.get_index()).stickman_data = inventory_node.inventory[slot.get_index()]
		pass
	pass # Replace with function body.


func _on_stickman_inventory_inventory_stickman_removed() -> void:
	pass # Replace with function body.

extends Control
var inventory_node : Node
@export var Slot_scene = preload("res://Scenes/UI/stickman_slot.tscn")
var drag_data : StickmanData = null
var dragged_slot : Button
var dragged_slot_phantom : Sprite2D = Sprite2D.new()


func _ready() -> void:
	inventory_node = find_child("Inventory")
	if inventory_node : 
		instantiate_inventory()
	


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == true :
			get_tree().paused = false
			$PauseLabel.hide()
		else :
			get_tree().paused = true
			$PauseLabel.show()
	
	#if drag_data :
	#	dragged_slot_phantom.texture = dragged_slot.find_child("StickmanSpriteIcon").texture
	#	dragged_slot_phantom.position = get_global_mouse_position()
	#else : 
	#	dragged_slot_phantom = null


func instantiate_inventory():
	for inv_slot in range(inventory_node.inventory.size()) :
		var new_slot = Slot_scene.instantiate()
		new_slot.stickman_data = inventory_node.inventory[inv_slot]
		new_slot.name = "Inventory_Slot_"+str(inv_slot+1)
		
		if %HotbarHBbox.get_children().size() < inventory_node.HOTBAR_SIZE :
			%HotbarHBbox.add_child(new_slot)
			new_slot.connect("stickman_selected",_on_stickman_slot_stickman_selected)
		else : 
			%InventoryGrid.add_child(new_slot)


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


func _on_inventory_button_toggled(toggled_on: bool) -> void:
	if toggled_on and $UnitCreator.visible == false : 
		$Inventory.show()
	else :
		$Inventory.hide()


func _on_unit_creator_button_toggled(toggled_on: bool) -> void:
	if toggled_on and $Inventory.visible == false : 
		$UnitCreator.show()
	else :
		$UnitCreator.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered != null and hovered.get_class() == "Button" :
			if hovered.stickman_data :
				dragged_slot = hovered
				drag_data = hovered.stickman_data
	
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered != null and hovered.get_class() == "Button" and dragged_slot and dragged_slot.stickman_data != hovered.stickman_data :
			var temp : StickmanData = hovered.stickman_data
			hovered.stickman_data = drag_data
			dragged_slot.stickman_data = temp
			dragged_slot.update_sprite()
			hovered.update_sprite()
		if drag_data :
			dragged_slot = null
			drag_data = null

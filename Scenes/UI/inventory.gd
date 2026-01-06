extends Control
signal inventory_stickman_added(unit_data : StickmanData)
signal inventory_stickman_removed()

@export var stickman_scene := preload("res://Scenes/Units/stickman.tscn")
@export var Slot_scene := preload("res://Scenes/UI/stickman_slot.tscn")
@export var inventory_size : int = 20
@export var HOTBAR_SIZE := 10

var inventory: Array[Slot] = []
var selected_unit_data: StickmanData = null

var drag_data : StickmanData = null
var dragged_slot : Button
var dragged_slot_phantom : Sprite2D = Sprite2D.new()
var phantom_sprite := Sprite2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phantom_sprite.texture = preload("res://ressources/Sprites/Units/Stickman/Stickman White Tpose.png")
	phantom_sprite.modulate.a = 0.5
	add_child(phantom_sprite)
	phantom_sprite.visible = false
	
	inventory.resize(inventory_size)
	instantiate_inventory(inventory_size)
	
	var _kick_skill = preload("res://Scenes/Skills/ActiveSkills/Kick_Skill.tres").duplicate(true)
	var _burst_skill = preload("res://Scenes/Skills/ActiveSkills/SmallBurst_Skill.tres").duplicate(true)
	#var projectile_skill = preload("res://Scenes/Skills/ActiveSkills/BaseProjectile_Skill.tres").duplicate(true)
	
	add_unit(StickmanData.new())
	add_unit(StickmanData.new().with_scale(0.5))
	add_unit(StickmanData.new().with_scale(1.5))
	add_unit(StickmanData.new().randomized(0.5, 2.0))
	add_unit(StickmanData.new().with_points(10))
	add_unit(StickmanData.new().with_points(50))
	add_unit(StickmanData.new().with_points(150).with_scale(0.5))
	add_unit(StickmanData.new().with_scale(0.5).with_points(150))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if drag_data != null:
		phantom_sprite.modulate = Color(drag_data.color.r,drag_data.color.g,drag_data.color.b,0.5) 
		phantom_sprite.visible = true
		phantom_sprite.global_position = get_global_mouse_position()
	else:
		phantom_sprite.visible = false

func instantiate_inventory(inv_size:int) -> void:
	for i in range(inv_size):
		var new_slot = Slot_scene.instantiate()
		new_slot.stickman_data = null
		new_slot.name = "Inventory_Slot_"+str(i+1)
		
		if %HotbarHBbox.get_children().size() < HOTBAR_SIZE :
			%HotbarHBbox.add_child(new_slot)
			new_slot.connect("stickman_selected",_on_stickman_slot_stickman_selected)
		else : 
			%InventoryGrid.add_child(new_slot)
		inventory[i] = new_slot 

func add_unit(unit_data: StickmanData, _slot: int = -1):
	if _slot != -1 && _slot < inventory.size():
		inventory[_slot].stickman_data = unit_data
	else :
		for i in inventory.size() :
			if inventory[i].stickman_data == null :
				#print("adding unit to slot " + str(i))
				inventory[i].stickman_data = unit_data
				inventory[i].update_sprite()
				break
		
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

func get_hotbar_array(hotbar_length:int) -> Array[Node] :
	var hotbar_array : Array[Node]
	var i := 0
	while i <= hotbar_length :
		i+=1
		hotbar_array[i].stickman_data = inventory[i].stickman_data
	return hotbar_array

func print_inv() -> void:
	for i in inventory.size():
		var slot = inventory[i]
		if slot != null and slot.type != null:
			print("Slot (index) : " + str(i) + " Type = " + str(slot.type))
		else:
			pass
			#print("Slot (index) " + str(i) + " is empty or invalid!")

func _on_stickman_slot_stickman_selected(unit_data: StickmanData) -> void:
	if unit_data : 
		print("Unit ID : " + unit_data.id + " \nUnit DisplayName = " + unit_data.display_name)
	selected_unit_data = unit_data

func _on_stickman_inventory_inventory_stickman_added(_unit_data) -> void:
	for slot in inventory : 
		if slot.stickman_data : 
			pass

func _on_stickman_inventory_inventory_stickman_removed() -> void:
	pass # Replace with function body.


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
		var hovered = get_viewport().gui_get_hovered_control()
		#print(hovered)
		if hovered != null and hovered.get_class() == "Button" :
			if hovered.stickman_data :
				dragged_slot = hovered
				drag_data = hovered.stickman_data
	
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered != null and hovered.get_class() == "Button" and dragged_slot and dragged_slot.stickman_data != hovered.stickman_data :
			var temp : StickmanData = hovered.stickman_data
			selected_unit_data = temp
			hovered.stickman_data = drag_data
			dragged_slot.stickman_data = temp
			dragged_slot.update_sprite()
			hovered.update_sprite()
		if drag_data :
			dragged_slot = null
			drag_data = null

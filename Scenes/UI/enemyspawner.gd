extends Node

@export var UI_node : Control 
var stickman: PackedScene = preload("res://Scenes/Units/Stickman/stickman.tscn")
var stickman_data_resource: UnitData = UnitData.new()
var selected_stickmandata : UnitData 
var selected_team : Team

var random_spawn_toggle : bool = false
@export var random_spawn_delay : float = 10.0
var elapsed := 0.0

func _process(_delta: float) -> void:
	if random_spawn_toggle == true : 
		elapsed += _delta
		if elapsed >= random_spawn_delay :
			elapsed -= random_spawn_delay
			spawn_random_stickman()

func _input(event):
	if event is InputEventMouseButton and event.pressed :
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered != null && hovered.get_class() != "Control" :
			#print("Mouse clicked on UI element : ", hovered.name)
			return
		
		if event.button_index == MOUSE_BUTTON_LEFT :
			print("Spawned a stickman at " + str(event.position))
			
			if  UI_node.inventory_module.selected_unit_data : 
				selected_stickmandata = UI_node.inventory_module.selected_unit_data
				var temp_message : Array
				for i in selected_stickmandata.skill_list :
					temp_message.append(i.skill_name)
				#print("Stickmandata skill list = " +  str(temp_message))
				spawn_from_data(event.position, selected_stickmandata)
			else :
				print("No stickmanData provided, spawning default stickman")
				spawn_from_data(event.position, UnitData.new())
		
		if event.button_index == MOUSE_BUTTON_RIGHT :
			#print("Spawned a random stickman at " + str(event.position))
			spawn_random_stickman(event.position, UnitData.new())


func spawn_from_data(pos: Vector2, data: UnitData) -> void:
	if stickman == null or data == null:
		push_error("Missing stickman scene or data")
		return
	
	var unit := stickman.instantiate()
	unit.position = pos
	unit.apply_data(data.duplicated())
	
	for skill in data.skill_list:
		unit.skillModule.add_skill(skill.duplicate(true))
	
	get_tree().root.add_child(unit)
	

func spawn_random_stickman(pos: Vector2 = Vector2(randf_range(0.0,1152.0),randf_range(0.0,648.0)), data: UnitData = UnitData.new()):
	if stickman == null or data == null:
		push_error("Missing stickman scene or data")
		return
	
	#rewrite this to have random chance to have weapon, extra stats, onhit effects, etc
	var rand_data := data.with_random_modifiers(randi() % 3 + 1 )
	
	#rand_data.team = Team.registry.pick_random()
	
	var unit := stickman.instantiate()
	unit.apply_data(rand_data.duplicated())
	unit.position = pos
	get_tree().root.add_child(unit)

func load_weapons() -> Array[Weapon]:
	var weps : Array[Weapon] = []
	for file_name in DirAccess.get_files_at("res://ressources/Weapons/"):
		if (file_name.get_extension() == "tres"):
			weps.append(load("res://ressources/Weapons/"+file_name))
	return weps

func _on_random_spawn_button_pressed() -> void:
	random_spawn_toggle = !random_spawn_toggle

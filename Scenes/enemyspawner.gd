extends Node
@export var stickman: PackedScene
@export var stickman_data_resource: StickmanData 
@export var UI_node = Control
var selected_stickmandata : StickmanData 
var selected_team : Team

var red_team = Team.new("Red",Color(255,0,0))
var green_team = Team.new("Green",Color(0,255,0))
var blue_team = Team.new("Blue",Color(0,0,255))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed :
		
		#print(selected_stickmandata)
		#dont use spawning logic if clicking UI Elements
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
				spawn_stickman(event.position, selected_stickmandata)
			else :
				print("No stickmanData provided, spawning default stickman")
				spawn_default_stickman(event.position)
		
		if event.button_index == MOUSE_BUTTON_RIGHT :
			#print("Spawned a random stickman at " + str(event.position))
			spawn_random_stickman(event.position, 3.0)

func spawn_stickman(pos: Vector2,unit_data : StickmanData,team : Team = null):
	if stickman == null:
		push_error("No stickman scene assigned!")
		return
	
	var stickman_instance = stickman.instantiate()
	stickman_instance.apply_data(unit_data)
	stickman_instance.position = pos
	if team : 
		stickman_instance.team = team
	
	get_parent().add_child(stickman_instance)

func spawn_default_stickman(pos: Vector2,team : Team = null):
	if stickman == null:
		push_error("No stickman scene assigned!")
		return
	
	var stickman_instance = stickman.instantiate()
	stickman_instance.position = pos
	if team : 
		stickman_instance.team = team
	
	get_parent().add_child(stickman_instance)

func spawn_random_stickman(pos: Vector2, rand_multiplier,team : Team = null):
	if stickman == null:
		push_error("No stickman scene assigned!")
		return
	if stickman_data_resource == null:
		push_error("No stickman data resource assigned!")
		return
	
	var stickman_instance = stickman.instantiate()
	var randomized_data = stickman_data_resource.get_randomized_stickmanData(1.0, rand_multiplier)
	
	stickman_instance.apply_data(randomized_data) 
	
	if team : 
		stickman_instance.team = team
	else : 
		stickman_instance.team = [null,red_team,blue_team,green_team].pick_random()
	
	stickman_instance.position = pos
	get_parent().add_child(stickman_instance)

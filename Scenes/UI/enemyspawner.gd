extends Node

@export var UI_node : Control 
var stickman: PackedScene = preload("res://Scenes/Units/stickman.tscn")
var stickman_data_resource: StickmanData = StickmanData.new()
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
				spawn_from_data(event.position, selected_stickmandata)
			else :
				print("No stickmanData provided, spawning default stickman")
				spawn_from_data(event.position, StickmanData.new())
		
		if event.button_index == MOUSE_BUTTON_RIGHT :
			#print("Spawned a random stickman at " + str(event.position))
			spawn_random_stickman(event.position, StickmanData.new())


func spawn_from_data(pos: Vector2, data: StickmanData) -> void:
	if stickman == null or data == null:
		push_error("Missing stickman scene or data")
		return
	
	var unit := stickman.instantiate()
	unit.stats = data.stats.duplicate(true)
	unit.team = data.team
	unit.weapon = data.weapon
	unit.sprite_color = data.color
	for skill in data.skill_list:
		unit.skillModule.add_skill(skill.duplicate(true))
	unit.position = pos
	get_parent().add_child(unit)

func spawn_random_stickman(pos: Vector2, data: StickmanData):
	if stickman == null or data == null:
		push_error("Missing stickman scene or data")
		return
	
	var rand_data := data.randomized(1.0, 10.0, StickmanData.RandomizationType.ADD).duplicated()
	rand_data.team = Team.registry.pick_random()
	
	var unit := stickman.instantiate()
	unit.stats = rand_data.stats
	unit.team = rand_data.team
	
	var testdagger :Weapon = load("res://Scenes/Weapons/testdagger.tres")
	var testsword :Weapon = load("res://Scenes/Weapons/testsword.tres")
	var testhammer :Weapon = load("res://Scenes/Weapons/testhammer.tres")
	var randWeapon : Array[Weapon] = [testdagger,testsword,testhammer]
	unit.weapon = randWeapon.pick_random()
	#print("Stickman weapon chosen : " + str(unit.weapon.weaponName))
	
	unit.sprite_color = rand_data.color
	for skill in rand_data.skill_list:
		unit.add_skill(skill.duplicate(true))
	unit.position = pos
	get_parent().add_child(unit)

extends Node
@export var stickman: PackedScene
@export var stickman_data = StickmanData
@export var inventory = Node

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
		
		#ignore 
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered != null && hovered.get_class() != "Control" :
			#print("Mouse clicked on UI element : ", hovered.name)
			return
		
		if event.button_index == MOUSE_BUTTON_LEFT :
			#print("Spawned a stickman at " + str(event.position))
			spawn_default_stickman(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT :
			#print("Spawned a random stickman at " + str(event.position))
			spawn_random_stickman(event.position, 5)

func spawn_default_stickman(pos: Vector2):
	if stickman == null:
		push_error("No stickman scene assigned!")
		return
	
	var stickman_instance = stickman.instantiate()
	stickman_instance.position = pos
	
	stickman_instance.team = red_team
	get_parent().add_child(stickman_instance)

func spawn_random_stickman(pos: Vector2, rand_multiplier):
	if stickman == null:
		push_error("No stickman scene assigned!")
		return
	if stickman_data == null:
		push_error("No stickman data resource assigned!")
		return
	
	var stickman_instance = stickman.instantiate()
	var stickman_data_resource: StickmanData = stickman_data.new()
	var randomized_data = stickman_data_resource.get_randomized_stats(1.0, rand_multiplier)
	
	stickman_instance.speed = randomized_data.speed
	stickman_instance.health = randomized_data.health
	stickman_instance.health_regen = randomized_data.health_regen
	stickman_instance.damage = randomized_data.damage
	stickman_instance.attack_speed = randomized_data.attack_speed
	stickman_instance.attack_range = randomized_data.attack_range
	stickman_instance.knockback = randomized_data.knockback
	stickman_instance.sprite_color = randomized_data.color
	
	stickman_instance.team = blue_team
	
	stickman_instance.position = pos
	get_parent().add_child(stickman_instance)

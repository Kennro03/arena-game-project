extends Node
@export var stickman: PackedScene

var red_team := preload("res://ressources/Teams/Red_Team.tres")
var blue_team := preload("res://ressources/Teams/Blue_Team.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
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
	
	var stickman_instance = stickman.instantiate()
	
	stickman_instance.speed = randi_range((stickman_instance.speed/rand_multiplier),(stickman_instance.speed*rand_multiplier))
	stickman_instance.health = randi_range((stickman_instance.health/rand_multiplier),(stickman_instance.health*rand_multiplier))
	stickman_instance.health_regen = randi_range((stickman_instance.health_regen/rand_multiplier),(stickman_instance.health_regen*rand_multiplier))
	stickman_instance.damage = randi_range((stickman_instance.damage/rand_multiplier),(stickman_instance.damage*rand_multiplier))
	stickman_instance.attack_speed = randi_range((stickman_instance.attack_speed/rand_multiplier),(stickman_instance.attack_speed*rand_multiplier))
	stickman_instance.attack_range = randi_range((stickman_instance.attack_range/rand_multiplier),(stickman_instance.attack_range*rand_multiplier))
	stickman_instance.knockback = randi_range((stickman_instance.knockback/rand_multiplier),(stickman_instance.knockback*rand_multiplier))
	
	stickman_instance.team = blue_team
	stickman_instance.sprite_color = Color(randf(),randf(),randf())
	
	stickman_instance.position = pos
	get_parent().add_child(stickman_instance)

class_name Stickman extends Node2D
var StateMachine = preload("res://Scenes/StateMachine/state_machine.gd")

@export var speed := 100.0:
	get:
		return speed
	set(value):
		speed = value
@export var health := 100.0:
	get:
		return health
	set(value):
		health = value
@export var damage := 20.0
@export var attack_speed := 1.0
@export var aggro_range := 750.0
@export var range := 50.0
@export var knockback := 100.0

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 800.0 
var enemies_group_name := "Stickmen"

func _ready():
	add_to_group(enemies_group_name)


func get_closest_stickman(max_distance := INF) -> Node2D:
	var closest = null
	var min_dist = max_distance
	for other in get_tree().get_nodes_in_group(enemies_group_name):
		if other == self:
			continue
		var dist = position.distance_to(other.position)
		if dist < min_dist:
			min_dist = dist
			closest = other
	return closest

func get_target_position_vector(target_position := Vector2()) -> Vector2:
	var closest_target_vector : Vector2
	closest_target_vector = target_position-self.position
	
	#print("owner position : " + str(self.position) + ", target position : " + str(target_position))
	#print("Closest target vector : " + str(closest_target_vector))
	
	return closest_target_vector

func position_proximity_check(position : Vector2, max_distance : float) :
	if self.position.distance_to(position) <= max_distance :
		return true
	else :
		return false

func target_proximity_check(target : Node2D, max_distance : float) :
	if self.position.distance_to(target.position) <= max_distance :
		return true
	else :
		return false

func hit(target : Node2D, damage : float):
	target.health = target.health-damage
	if target.has_method("update_health") :
		target.update_health()
	if target.health <= 0:
		target.queue_free()

func punch(target : Node2D, damage : float, knockback_direction: Vector2, knockback_force: float):
	target.health = target.health-damage
	if target.has_method("update_health") :
		target.update_health()
	if target.health <= 0:
		target.queue_free()
	elif target.has_method("receive_knockback") and knockback_force >= 0.1 and knockback_direction != null:
		target.apply_knockback(target, knockback_direction, knockback_force)

func apply_knockback(target: Node2D, direction: Vector2, force: float):
	if target.has_method("receive_knockback"):
		target.receive_knockback(direction.normalized() * force)

func receive_knockback(force: Vector2):
	knockback_velocity += force

func update_health():
	%HealthBar.value = health

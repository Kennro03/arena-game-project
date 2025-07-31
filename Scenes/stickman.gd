class_name Stickman extends Node2D

@export var speed := 100.0:
	get:
		return speed
	set(value):
		speed = value
@export var health := 100.0:
	get:
		return health
	set(value):
		health = maxf(0.0, value)
@export var health_regen := 3.0:
	get:
		return health_regen
	set(value):
		health_regen = value
@export var damage := 20.0:
	get:
		return damage
	set(value):
		damage = maxf(0.0, value)
@export var attack_speed := 1.0:
	get:
		return attack_speed
	set(value):
		attack_speed = maxf(0.0, value)
@export var aggro_range := 750.0:
	get:
		return aggro_range
	set(value):
		aggro_range = value
@export var attack_range := 60.0:
	get:
		return attack_range
	set(value):
		attack_range = value
@export var knockback := 60.0:
	get:
		return knockback
	set(value):
		knockback = value

@export var sprite_color := Color(255.0,255.0,255.0)
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 1000.0 
var enemies_group_name := "Stickmen"

func _ready():
	%HealthBar.max_value = health
	get_node("Sprite").modulate = sprite_color
	add_to_group(enemies_group_name)

func get_closest_stickman(max_distance := INF) -> Node2D:
	var closest = null
	for other in get_tree().get_nodes_in_group(enemies_group_name):
		if other == self:
			continue
		var dist = position.distance_to(other.position)
		if dist < max_distance:
			max_distance = dist
			closest = other
	return closest

func get_target_position_vector(target_position := Vector2()) -> Vector2:
	var closest_target_vector : Vector2
	closest_target_vector = target_position-self.position
	
	#print("owner position : " + str(self.position) + ", target position : " + str(target_position))
	#print("Closest target vector : " + str(closest_target_vector))
	
	return closest_target_vector

func position_proximity_check(target_position : Vector2, max_distance : float) :
	if self.position.distance_to(target_position) <= max_distance :
		return true
	else :
		return false

func target_proximity_check(target : Node2D, max_distance : float) :
	if self.position.distance_to(target.position) <= max_distance :
		return true
	else :
		return false

func hit(target : Node2D):
	target.health = target.health-damage
	if target.has_method("update_health") :
		target.update_health()
	if target.health <= 0:
		target.queue_free()

func punch(target : Node2D, knockback_direction: Vector2, knockback_force: float):
	target.health = target.health-damage
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

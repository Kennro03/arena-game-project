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
@export var health_regen := 2.0:
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
@export var knockback := 100.0:
	get:
		return knockback
	set(value):
		knockback = value

@export var dodge_probability := 10.0
@export var parry_probability := 5.0
@export var block_probability := 40.0
@export var flat_block_power := 0.0
@export var percent_block_power := 50.0

@export var team : Team

@export var sprite_color := Color(255.0,255.0,255.0)
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 1000.0 
var enemies_group_name := "Stickmen"
var idle_animations = ["Idle"]
var punch_animations = ["punch_1","punch_2"]
var dodge_animations = ["dodge_1","dodge_2"]

func _ready():
	%HealthBar.max_value = health
	get_node("Sprite").modulate = sprite_color
	add_to_group(enemies_group_name)

func get_closest_stickman(max_distance := INF, group_name : String = enemies_group_name) -> Node2D:
	var closest = null
	for other in get_tree().get_nodes_in_group(group_name):
		if other == self:
			continue
		elif check_if_ally(other) :
			continue
		var dist = position.distance_to(other.position)
		if dist < max_distance:
			max_distance = dist
			closest = other
	return closest

func get_target_position_vector(target_position := Vector2()) -> Vector2:
	var closest_target_vector : Vector2
	closest_target_vector = target_position-self.position
	
	return closest_target_vector

func position_proximity_check(target_position : Vector2, max_distance : float) :
	if self.position.distance_to(target_position) <= max_distance :
		return true
	else :
		return false

func target_proximity_check(target : Node2D, max_distance : float) :
	if target != null and self.position.distance_to(target.position) <= max_distance :
		return true
	else :
		return false

func punch(target : Node2D, punch_damage : float = 0.0, knockback_direction: Vector2  = Vector2(0,0), knockback_force: float  = 0.0):
	if target.has_method("take_hit") :
		target.take_hit(punch_damage,knockback_direction,knockback_force)

func check_if_ally(target : Node2D) -> bool :
	if is_instance_valid(team) and is_instance_valid(target.team) :
		if team.team_name == target.team.team_name :
			return true
		else :
			return false
	else : 
		return false

func apply_knockback(target: Node2D, direction: Vector2, force: float):
	if target.has_method("receive_knockback"):
		target.receive_knockback(direction.normalized() * force)

func receive_knockback(force: Vector2):
	knockback_velocity += force

func try_to_dodge():
	if randf_range(0.0,100.0)<=dodge_probability:
		return true
	else :
		return false

func try_to_parry():
	if randf_range(0.0,100.0)<=parry_probability:
		return true
	else :
		return false

func try_to_block():
	if randf_range(0.0,100.0)<=block_probability:
		return true
	else :
		return false

func take_damage(incoming_damage) :
	health = health - incoming_damage
	%DamagePopupMarker.damage_popup(str(incoming_damage))

func block(incoming_damage):
	var flat_blocked_damage = maxf((incoming_damage-flat_block_power),0.0)
	var blocked_damage = flat_blocked_damage - ((flat_blocked_damage / 100)*percent_block_power)
	health -= blocked_damage
	%DamagePopupMarker.damage_popup("Blocked!", 0.5)
	%DamagePopupMarker.damage_popup(str(blocked_damage))
	%AnimationPlayer.play("block")

func parry(_incoming_damage):
	%AnimationPlayer.play("parry")
	%DamagePopupMarker.damage_popup("Parry!", 1.0)

func dodge(_incoming_damage):
	%AnimationPlayer.play(dodge_animations[randi() % dodge_animations.size()])
	apply_knockback(self, Vector2(randf(),randf()), 250.0)

func take_hit(hit_damage : float = 0.0, knockback_direction : Vector2 = Vector2(0,0), knockback_force : float = 0.0) :
	if try_to_dodge() :
		dodge(hit_damage)
	elif try_to_parry() :
		parry(hit_damage)
	elif try_to_block() :
		block(hit_damage)
		
		if knockback_force >= 0.1 and knockback_direction != Vector2(0,0) :
			apply_knockback(self, knockback_direction, knockback_force/2)
	else :
		take_damage(hit_damage)
		if knockback_force >= 0.1 and knockback_direction != Vector2(0,0) :
			apply_knockback(self, knockback_direction, knockback_force)
	
	if health <= 0:
		queue_free()

func update_health():
	%HealthBar.value = health

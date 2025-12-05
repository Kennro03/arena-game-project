class_name Stickman extends Node2D
var spriteNode
var animationPlayerNode

@export var unit_data : Unit = Unit.new().duplicate()

@export var weapon : Weapon = null
var health := 100.0:
	set(value):
		if value > 0.0 :
			health = clamp(value,0.0,unit_data.max_health)
		else : 
			die()
var last_attack_time := 0.0
var is_casting: bool = false
var is_stunned: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 1000.0 
var enemies_group_name := "Stickmen"

func _ready():
	spriteNode = $StickmanSprite
	animationPlayerNode = $StickmanSprite/AnimationPlayer
	spriteNode.bodyColor = unit_data.sprite_color
	spriteNode.selfmodulate()
	if unit_data.team != null :
		var flag: PackedScene = preload("res://Scenes/flag.tscn")
		var flag_instance
		flag_instance = flag.instantiate()
		flag_instance.position.y -= 80
		flag_instance.modulate = unit_data.team.team_color
		add_child(flag_instance)
	
	%HealthBar.max_value = health
	add_to_group(enemies_group_name)
	
	if weapon == null :
		weapon = preload("res://Scenes/Weapons/fists.tres") 

func can_hit()-> bool :
	if last_attack_time >= 1.0/unit_data.attack_speed:
		return true
	else : 
		return false

func get_closest_unit(max_distance := INF, group_name : String = enemies_group_name) -> Node2D:
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

func attack(target : Node2D, punch_damage : float = 0.0, knockback_direction: Vector2  = Vector2(0,0), knockback_force: float  = 0.0):
	if weapon : 
		weapon.hit(target)
	else : 
		print("Could not find weapon")
		var hit_result = HitData.new(punch_damage,knockback_direction,knockback_force)
		if target.has_method("resolve_hit") :
			target.resolve_hit(hit_result)

func check_if_ally(target : Node2D) -> bool :
	if is_instance_valid(unit_data.team) and is_instance_valid(target.unit_data.team) :
		if unit_data.team.team_name == target.unit_data.team.team_name :
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

func take_damage(incoming_damage) :
	health = health - incoming_damage
	%DamagePopupMarker.damage_popup(str(incoming_damage),0.75+0.01*incoming_damage,Color(1,1-(incoming_damage*0.02),1-(incoming_damage*0.02)))

func block(hit: HitData):
	var flat_blocked_damage = maxf((hit.damage-unit_data.flat_block_power),0.0)
	var blocked_damage = flat_blocked_damage - ((flat_blocked_damage / 100)*unit_data.percent_block_power)
	health -= blocked_damage
	%DamagePopupMarker.damage_popup("Blocked!", 0.5,Color("LightBlue"))
	%DamagePopupMarker.damage_popup(str(blocked_damage))
	animationPlayerNode.play("block")

func parry(_hit: HitData):
	animationPlayerNode.play("parry")
	%DamagePopupMarker.damage_popup("Parry!", 1.0,Color("Gold"))

func dodge(_hit: HitData):
	spriteNode.play_dodge_animation()
	apply_knockback(self, Vector2(randf(),randf()), 250.0)

func resolve_hit(hit_result : HitData) :
	if randf_range(0.0,100.0)<=unit_data.dodge_probability and is_casting==false:
		dodge(hit_result)
	elif randf_range(0.0,100.0)<=unit_data.parry_probability and is_casting==false:
		parry(hit_result)
	elif randf_range(0.0,100.0)<=unit_data.block_probability and is_casting==false:
		block(hit_result)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force/2)
	else :
		take_damage(hit_result.damage)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force)

func update_health():
	%HealthBar.value = health

func apply_data(data: StickmanData) -> void:
	self.unit_data.speed = data.speed
	self.unit_data.max_health = data.max_health
	self.health = data.health
	self.unit_data.health_regen = data.health_regen
	self.unit_data.damage = data.damage
	self.unit_data.attack_speed = data.attack_speed
	self.unit_data.aggro_range = data.aggro_range
	self.unit_data.attack_range = data.attack_range
	self.unit_data.knockback = data.knockback
	self.unit_data.dodge_probability = data.dodge_probability
	self.unit_data.parry_probability = data.parry_probability
	self.unit_data.block_probability = data.block_probability
	self.unit_data.flat_block_power = data.flat_block_power
	self.unit_data.percent_block_power = data.percent_block_power
	self.unit_data.sprite_color = data.color
	self.unit_data.team = data.team
	
	%SkillModule.skill_list = data.skill_list

var deathmessagelist : Array[String] = ["DEAD","OOF","RIP","OUCH","BYE",":(","x_x"]
func die() -> void:
	%DamagePopupMarker.damage_popup(deathmessagelist.pick_random(),1.25,Color("DARKRED"),0.25)
	queue_free()

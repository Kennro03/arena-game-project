class_name Stickman extends Node2D
var spriteNode
var animationPlayerNode

@export var type = "Default Stickman"
@export var icon: Texture2D = null
@export var description: String = "A regular Stickman."
@export var sprite_color := Color(255.0,255.0,255.0)
@export var team : Team = null

@export var stats : Stats
@export var weapon : Weapon = null


var last_attack_time := 0.0
var is_casting: bool = false
var is_stunned: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 1000.0 
var enemies_group_name := "Stickmen"

func _ready():
	spriteNode = $StickmanSprite
	animationPlayerNode = $StickmanSprite/AnimationPlayer
	spriteNode.bodyColor = sprite_color
	spriteNode.selfmodulate()
	if team != null :
		var flag: PackedScene = preload("res://Scenes/flag.tscn")
		var flag_instance
		flag_instance = flag.instantiate()
		flag_instance.position.y -= 80
		flag_instance.modulate = team.team_color
		add_child(flag_instance)
	
	%HealthBar.max_value = stats.health
	add_to_group(enemies_group_name)
	
	if weapon == null :
		weapon = preload("res://Scenes/Weapons/fists.tres") 

func can_hit()-> bool :
	if last_attack_time >= 1.0/weapon.attack_speed:
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

func take_damage(incoming_damage) :
	stats.health = stats.health - incoming_damage
	%DamagePopupMarker.damage_popup(str(incoming_damage),0.75+0.01*incoming_damage,Color(1,1-(incoming_damage*0.02),1-(incoming_damage*0.02)))

func block(hit: HitData):
	var flat_blocked_damage = maxf((hit.damage-stats.current_flat_block_power),0.0)
	var blocked_damage = flat_blocked_damage - ((flat_blocked_damage / 100)*stats.current_percent_block_power)
	stats.health -= blocked_damage
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
	if randf_range(0.0,100.0)<=stats.current_dodge_probability and is_casting==false:
		dodge(hit_result)
	elif randf_range(0.0,100.0)<=stats.current_parry_probability and is_casting==false:
		parry(hit_result)
	elif randf_range(0.0,100.0)<=stats.current_block_probability and is_casting==false:
		block(hit_result)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force/2)
	else :
		take_damage(hit_result.damage)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force)

func update_healthBar():
	%HealthBar.value = stats.health

func apply_data(data: StickmanData) -> void:
	#Replace all of this to use the new stat resource instead
	self.stats.base_movement_speed = data.speed
	self.stats.base_max_health = data.max_health
	self.stats.base_health_regen = data.health_regen
	self.stats.base_dodge_probability = data.dodge_probability
	self.stats.base_parry_probability = data.parry_probability
	self.stats.base_block_probability = data.block_probability
	self.stats.base_flat_block_power = data.flat_block_power
	self.stats.base_percent_block_power = data.percent_block_power
	
	self.sprite_color = data.color
	self.team = data.team
	
	%SkillModule.skill_list = data.skill_list

var deathmessagelist : Array[String] = ["DEAD","OOF","RIP","OUCH","BYE",":(","x_x"]
func die() -> void:
	%DamagePopupMarker.damage_popup(deathmessagelist.pick_random(),1.25,Color("DARKRED"),0.25)
	queue_free()

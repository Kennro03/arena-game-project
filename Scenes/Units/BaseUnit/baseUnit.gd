extends Node2D
class_name BaseUnit
signal hit_received(hit_data: HitData)

@onready var spriteNode = $SpriteModule
@onready var animationPlayerNode = $SpriteModule/AnimationPlayer
@onready var healthBar := %HealthBar
@onready var shieldBar := %ShieldBar
@onready var StatusEffectModule : Node2D = $StatusEffectModule
@onready var skillModule : Node = $SkillModule

@export var id: String = "Basic_Unit"
@export var display_name: String = "Unit"
@export var show_name: bool = false
@export var description: String = "A regular unit."
@export var icon: Texture2D = null
@export var sprite_color:= Color.WHITE
@export var team: Team
@export var stats : Stats = Stats.new()
@export var weapon : Weapon = null
@export var default_weapon : Weapon = preload("res://ressources/Weapons/fists.tres")

var summoner : BaseUnit = null  
var is_action_locked := false
var last_attack_time:= 0.0
var is_casting: bool = false
var is_stunned: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay:= 1000.0 
var deathmessagelist : Array[String] = ["DEAD","OOF","RIP","OUCH","BYE",":(","x_x"]

const BASE_BAR_WIDTH : float = 50.0
const MIN_BAR_WIDTH : float = 25.0
const MAX_BAR_WIDTH : float = 100.0
const HEALTH_SCALE_REFERENCE : float = 100.0 

func _ready():
	spriteNode.bodyColor = sprite_color
	spriteNode.selfmodulate()
	
	%NameLabel.text = display_name
	%NameLabel.visible = show_name
	
	if team != null :
		var flag: PackedScene = preload("res://Scenes/flag.tscn")
		var flag_instance
		flag_instance = flag.instantiate()
		flag_instance.position.y -= 80
		flag_instance.modulate = team.team_color
		add_child(flag_instance)
	
	add_to_group("Units")
	update_healthBar(stats.health,stats.current_max_health)
	stats.connect("health_changed",update_healthBar)
	stats.connect("health_depleted",die)
	stats.connect("shield_changed",update_shieldBar)
	stats.connect("shield_depleted",hide_shieldBar)
	animationPlayerNode.animation_finished.connect(_on_anim_finished)
	
	#stats.print_attributes.call_deferred()
	#stats.print_stats.call_deferred()

func update_healthBar(_health, _max_health) -> void :
	healthBar.max_value = _max_health
	healthBar.value = _health
	var scaled_width := BASE_BAR_WIDTH * sqrt(_max_health / HEALTH_SCALE_REFERENCE)
	healthBar.custom_minimum_size.x = clampf(scaled_width, MIN_BAR_WIDTH, MAX_BAR_WIDTH)

func update_shieldBar(_shield, _max_shield) -> void :
	shieldBar.max_value = _max_shield
	shieldBar.value = _shield
	shieldBar.visible = _shield > 0.0
	var scaled_width := BASE_BAR_WIDTH * sqrt(_max_shield / HEALTH_SCALE_REFERENCE)
	shieldBar.custom_minimum_size.x = clampf(scaled_width, MIN_BAR_WIDTH, MAX_BAR_WIDTH)

func hide_shieldBar() -> void :
	shieldBar.visible = false

func _on_anim_finished(_anim_name):
	is_action_locked = false

func can_hit()-> bool :
	if last_attack_time >= 1.0/weapon.current_attack_speed :
		return true
	else : 
		return false

func get_units_in_group(group_name: String) -> Array:
	return get_tree().get_nodes_in_group(group_name)

func get_closest_unit(
	units: Array,
	max_distance := INF,
	filter: Callable = Callable()
) -> Node2D:
	var closest_unit : Node2D = null
	var closest_unit_dist := max_distance
	for other in units:
		if other == self:
			continue
		if filter.is_valid() and not filter.call(other):
			continue
		var dist := position.distance_to(other.position)
		if dist < closest_unit_dist:
			closest_unit_dist = dist
			closest_unit = other
	return closest_unit

func get_target_position_vector(target_position := Vector2()) -> Vector2:
	var closest_target_vector : Vector2
	closest_target_vector = target_position-self.position
	return closest_target_vector

func position_proximity_check(target_position : Vector2, max_distance : float) -> bool :
	if self.position.distance_to(target_position) <= max_distance :
		return true
	else :
		return false

func target_proximity_check(target : Node2D, max_distance : float) -> bool :
	if target != null and self.position.distance_to(target.position) <= max_distance :
		return true
	else :
		return false

#Returns true when stickman is close enought to a target to start attacking, to dictate when it should stop moving towards a target
func melee_close_range_check(target : Node2D) -> bool : 
	ensure_weapon()
	if target != null and self.position.distance_to(target.position) <= max(50,weapon.current_attack_range/1.3) :
		return true
	else :
		return false

#Returns true as long as target is in melee range
func melee_range_check(target : Node2D) -> bool : 
	ensure_weapon()
	if target != null and self.position.distance_to(target.position) <= max(50,weapon.current_attack_range) :
		return true
	else :
		return false

func attack(target : Node2D):
	ensure_weapon()
	if is_action_locked:
		return
	
	var hit := HitData.new(owner)
	hit.is_critical = randf() <= stats.current_crit_chance / 100.0
	hit.crit_mult = stats.current_crit_damage
	hit.knockback_direction = get_target_position_vector(target.global_position).normalized()
	hit.hit_owner = self
	weapon.hit(target, hit)

func get_effective_team() -> Team:
	if summoner != null:
		return summoner.get_effective_team()  # inherit summoner's team dynamically
	return team

# Returns the top-level non-summoned unit in the chain
func get_summoner_root() -> BaseUnit:
	if summoner == null:
		return self
	return summoner.get_summoner_root()

func check_if_ally(target : Node2D) -> bool :
	if not is_instance_valid(target):
		printerr("Instance not valid during ally check")
		return false
	
	var my_root := get_summoner_root()
	var their_root : BaseUnit = target.get_summoner_root() if target.has_method("get_summoner_root") else target
	if my_root == their_root and my_root != null:
		print("same root")
		return true
	
	var my_team := get_effective_team()
	var their_team : Team = target.get_effective_team() if target.has_method("get_effective_team") else target.team
	if not is_instance_valid(my_team) or not is_instance_valid(their_team):
		return false
	return my_team.team_name == their_team.team_name



func apply_knockback(target: Node2D, direction: Vector2, force: float):
	if target.has_method("receive_knockback"):
		target.receive_knockback(direction.normalized() * force)

func receive_knockback(force: Vector2):
	knockback_velocity += force

func take_damage(incoming_damage) :
	incoming_damage += stats.current_flat_damage_taken
	incoming_damage *= stats.current_percent_damage_taken
	incoming_damage = round(incoming_damage * pow(10.0, 2)) / pow(10.0, 2)
	if stats.shield > 0.0 and stats.shield > incoming_damage :
		stats.shield -= incoming_damage
		%DamagePopupMarker.damage_popup(str(incoming_damage),0.5+0.01*incoming_damage,Color(0.6, 0.8, 0.8, 1.0))
	elif stats.shield > 0.0 and stats.shield < incoming_damage :
		incoming_damage -= stats.shield
		%DamagePopupMarker.damage_popup(str(incoming_damage),0.5+0.01*incoming_damage,Color(0.6, 0.8, 0.8, 1.0))
		stats.shield = 0.0
		stats.health = stats.health - incoming_damage
		%DamagePopupMarker.damage_popup(str(incoming_damage),0.75+0.01*incoming_damage,Color(1,1-(incoming_damage*0.02),1-(incoming_damage*0.02)))
	else :
		stats.health = stats.health - incoming_damage
		%DamagePopupMarker.damage_popup(str(incoming_damage),0.75+0.01*incoming_damage,Color(1,1-(incoming_damage*0.02),1-(incoming_damage*0.02)))

func block(_hit: HitData):
	var flat_blocked_damage = maxf((_hit.base_damage-stats.current_flat_block_power),0.0)
	var blocked_damage = flat_blocked_damage - ((flat_blocked_damage / 100)*stats.current_percent_block_power)
	%DamagePopupMarker.damage_popup("Blocked!", 0.5,Color("LightBlue"))
	take_damage(blocked_damage) 
	animationPlayerNode.play("block")
	
	if (_hit.hit_owner.weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) and (weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) :
		$ParticleModule.emit_block_particles()

func parry(_hit: HitData):
	animationPlayerNode.play("parry")
	%DamagePopupMarker.damage_popup("Parry!", 1.0,Color("Gold"))
	
	if (_hit.hit_owner.weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) and (weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) :
		$ParticleModule.emit_parry_particles()

func dodge(_hit: HitData):
	spriteNode.play_dodge_animation()
	apply_knockback(self, Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0)), 250.0)

func resolve_hit(hit_result : HitData) :
	if randf_range(0.0,100.0)<=stats.current_dodge_probability and is_casting==false and is_stunned==false :
		hit_result.outcome = HitData.HitOutcome.DODGE
		dodge(hit_result)
	elif randf_range(0.0,100.0)<=stats.current_parry_probability and is_casting==false and is_stunned==false :
		hit_result.outcome = HitData.HitOutcome.PARRY
		parry(hit_result)
	elif randf_range(0.0,100.0)<=stats.current_block_probability and is_casting==false and is_stunned==false :
		hit_result.outcome = HitData.HitOutcome.BLOCK
		block(hit_result)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force/2)
		for passive in hit_result.hit_owner.weapon.onHitPassives :
			passive.on_hit(hit_result)
		hit_received.emit(hit_result)
	else :
		hit_result.outcome = HitData.HitOutcome.HIT
		take_damage(hit_result.base_damage)
		_apply_passives(hit_result)
		for effect in hit_result.status_effects :
			#print("Resolve step : Applying " + str(effect.Status_effect_name))
			%StatusEffectModule.apply_status_effect(effect)
		
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force)
		if hit_result.hit_owner.weapon.weaponType != weapon.WeaponTypeEnum.UNARMED :
			$ParticleModule.emit_hit_particles()
		hit_received.emit(hit_result)

func _apply_passives(hit_result: HitData) -> void:
	for passive in hit_result.hit_owner.weapon.onHitPassives:
		if _passive_clears_outcome(passive, hit_result.outcome):
			passive.on_hit(hit_result)

func apply_data(data: UnitData) -> void:
	self.id = data.id
	self.display_name = data.display_name
	self.show_name = data.show_name
	self.description = data.description
	self.icon = data.icon
	self.sprite_color = data.color
	self.team = data.team
	
	self.stats = data.stats
	self.stats.setup_stats()
	equip_weapon(data.weapon) 
	%SkillModule.skill_list = data.skill_list

func die() -> void:
	%DamagePopupMarker.damage_popup(deathmessagelist.pick_random(),1.25,Color("DARKRED"),0.25)
	queue_free()

func ensure_weapon() -> void:
	var wep : Weapon = weapon if weapon != null else default_weapon
	if wep != weapon :
		equip_weapon(wep.duplicate(true))

func equip_weapon(_wep : Weapon = preload("res://ressources/Weapons/fists.tres").duplicate(true)) -> void:
	#print("Equipping weapon : " + str(_wep.weaponName))
	if weapon and weapon.attack_performed.is_connected(_on_weapon_attack):
		weapon.remove_owner_buffs(stats)
		weapon.clear_weapon_buffs()
		weapon.attack_performed.disconnect(_on_weapon_attack)
		stats.changed.disconnect(weapon._on_owner_stats_change)
	weapon = _wep.duplicate(true)
	weapon.owner = self
	weapon.apply_owner_buffs(stats)
	weapon.setup_stats()
	
	$SpriteModule/BodySprite.texture = weapon.spriteSheet
	
	stats.changed.connect(weapon._on_owner_stats_change)
	weapon.attack_performed.connect(_on_weapon_attack)

func _on_weapon_attack(attack_type: Weapon.AttackTypeEnum, _endlag: float = 0.0) -> void:
	#print("Attack performed : " + Weapon.AttackTypeEnum.keys()[attack_type].to_lower())
	spriteNode.play_attack_animation(attack_type,weapon)
	is_action_locked = true

func _passive_clears_outcome(passive: OnHitPassive, outcome: HitData.HitOutcome) -> bool:
	match outcome:
		HitData.HitOutcome.DODGE: 
			return passive.triggers_on_dodge
		HitData.HitOutcome.BLOCK: 
			return passive.triggers_on_block
		HitData.HitOutcome.PARRY: 
			return passive.triggers_on_parry
		_: return true  # HIT always triggers

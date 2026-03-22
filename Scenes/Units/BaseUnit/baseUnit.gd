extends Node2D
class_name BaseUnit
signal hit_received(hit_data: HitData)
signal unit_clicked(unit: BaseUnit)
signal unit_died(unit: BaseUnit)

@onready var animationPlayer = %AnimationPlayer
@onready var healthBar := %HealthBar
@onready var shieldBar := %ShieldBar
@onready var spriteModule = $SpriteModule
@onready var statusEffectModule : StatusEffectModule = $StatusEffectModule
@onready var skillModule : SkillModule = $SkillModule
@onready var displayModule : DisplayModule = $DisplayModule
@onready var particleModule : ParticleModule = $ParticleModule
@onready var drag_and_drop_component: DragAndDrop = %DragAndDropComponent
@onready var velocity_based_rotation_component: VelocityBasedRotation = %VelocityBasedRotationComponent
@onready var outline_highlight_component: OutlineHighlighter = %OutlineHighlightComponent

@export var id: String = "BaseUnit"
@export var display_name: String = "BaseUnit"
@export var description: String = "The template used to create units."

@export_group("Visuals")
@export var icon: Texture2D = null
@export var sprite_color:= Color.WHITE
@export var show_name: bool = true
@export var show_health: bool = true
@export var weapon_spritesheets: Dictionary = {
	Weapon.WeaponTypeEnum.UNARMED: PlaceholderTexture2D.new(),
}

@export_group("Interactions")
@export var team: Team
@export var stats : Stats = Stats.new()
@export var weapon : Weapon = null
@export var default_weapon : Weapon = null

var summoner : BaseUnit = null  
var is_action_locked := false
var is_casting: bool = false
var is_stunned: bool = false
var last_attack_time:= 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay:= 1000.0 
var deathmessagelist : Array[String] = ["DEAD","OOF","RIP","OUCH","BYE",":(","x_x"]
var active: bool = true:
	set(value):
		active = value
		if active:
			_on_activated.call_deferred()
		else:
			_on_deactivated.call_deferred()

const BASE_BAR_WIDTH : float = 50.0
const MIN_BAR_WIDTH : float = 25.0
const MAX_BAR_WIDTH : float = 100.0
const HEALTH_SCALE_REFERENCE : float = 100.0 

func _ready():
	add_to_group("Units")
	spriteModule.bodyColor = sprite_color
	spriteModule.selfmodulate()
	ensure_weapon()
	
	%NameLabel.text = display_name
	%NameLabel.visible = show_name
	set_team_flag()
	
	if not Engine.is_editor_hint():
		drag_and_drop_component.drag_started.connect(_on_drag_started)
		drag_and_drop_component.drag_canceled.connect(_on_drag_canceled)
	
	set_healthbar_visibility(show_health)
	if show_health :
		update_healthBar(stats.health,stats.current_max_health)
		stats.connect("health_changed",update_healthBar)
		stats.connect("shield_changed",update_shieldBar)
		stats.connect("shield_depleted",hide_shieldBar)
	stats.connect("health_depleted",die)
	
	animationPlayer.animation_finished.connect(_on_anim_finished)
	#stats.print_attributes.call_deferred()
	#stats.print_stats.call_deferred()

func _on_activated() -> void:
	$StateMachine.process_mode = Node.PROCESS_MODE_PAUSABLE
	velocity_based_rotation_component.enabled = false

func _on_deactivated() -> void:
	$StateMachine.process_mode = Node.PROCESS_MODE_DISABLED
	velocity_based_rotation_component.enabled = true
	#animationPlayer.play("BaseUnit/idle")

func set_team_flag()->void:
	if team != null and team.flagVisible == true :
		var flag: PackedScene = preload("res://Scenes/flag.tscn")
		var flag_instance
		flag_instance = flag.instantiate()
		flag_instance.position.y -= 80
		flag_instance.modulate = team.team_color
		add_child(flag_instance)

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

func set_healthbar_visibility(vis : bool)->void:
	healthBar.visible = vis

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
	if weapon :
		if target != null and self.position.distance_to(target.position) <= max(50,weapon.current_attack_range/1.3) :
			return true
	return false

#Returns true as long as target is in melee range
func melee_range_check(target : Node2D) -> bool : 
	if weapon :
		if target != null and self.position.distance_to(target.position) <= max(50,weapon.current_attack_range) :
			return true
	return false

func attack(target : Node2D):
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
	spriteModule.play_block_animation()
	var flat_blocked_damage = maxf((_hit.base_damage-stats.current_flat_block_power),0.0)
	var blocked_damage = flat_blocked_damage - ((flat_blocked_damage / 100)*stats.current_percent_block_power)
	%DamagePopupMarker.damage_popup("Blocked!", 0.5,Color("LightBlue"))
	take_damage(blocked_damage) 
	if (_hit.hit_owner.weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) and (weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) :
		particleModule.emit_block_particles()

func parry(_hit: HitData):
	spriteModule.play_parry_animation()
	particleModule.DamagePopupMarker.damage_popup("Parry!", 1.0,Color("Gold"))
	if (_hit.hit_owner.weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) and (weapon.weaponType != weapon.WeaponTypeEnum.UNARMED) :
		particleModule.emit_parry_particles()

func dodge(_hit: HitData):
	spriteModule.play_dodge_animation()
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
			statusEffectModule.apply_status_effect(effect)
		
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2(0,0) :
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force)
		if hit_result.hit_owner.weapon.weaponType != weapon.WeaponTypeEnum.UNARMED :
			particleModule.emit_hit_particles()
		hit_received.emit(hit_result)

func _apply_passives(hit_result: HitData) -> void:
	for passive in hit_result.hit_owner.weapon.onHitPassives:
		if _passive_clears_outcome(passive, hit_result.outcome):
			passive.on_hit(hit_result)

func apply_data(data: UnitData) -> void:
	self.id = data.id
	self.display_name = data.display_name
	self.show_name = data.show_name
	self.show_health = data.show_health
	self.description = data.description
	self.icon = data.icon
	self.sprite_color = data.color
	self.team = data.team
	
	self.stats = data.stats
	self.stats.setup_stats()
	equip_weapon(data.weapon) 
	#skillModule.skill_list = data.skill_list

func die() -> void:
	%DamagePopupMarker.damage_popup(deathmessagelist.pick_random(),1.25,Color("DARKRED"),0.25)
	queue_free()

func ensure_weapon() -> void:
	if weapon == null :
		if default_weapon != null :
			equip_weapon(default_weapon.duplicate(true))
		else : 
			printerr("No weapon and no default_weapon set for " + str(self))

func equip_weapon(_wep : Weapon = null) -> void:
	#print("Equipping weapon : " + str(_wep.weaponName))
	if _wep == null:
		_wep = default_weapon
	
	if weapon and weapon.attack_performed.is_connected(_on_weapon_attack):
		weapon.remove_owner_buffs(stats)
		weapon.clear_weapon_buffs()
		weapon.attack_performed.disconnect(_on_weapon_attack)
		stats.changed.disconnect(weapon._on_owner_stats_change)
	
	if _wep :
		weapon = _wep.duplicate(true)
		weapon.owner = self
		weapon.apply_owner_buffs(stats)
		weapon.setup_stats()
		
		$SpriteModule.update_spritesheet.call_deferred()
		stats.changed.connect(weapon._on_owner_stats_change)
		weapon.attack_performed.connect(_on_weapon_attack)

func _on_weapon_attack(attack_type: Weapon.AttackTypeEnum, _endlag: float = 0.0) -> void:
	#print("Attack performed : " + Weapon.AttackTypeEnum.keys()[attack_type].to_lower())
	spriteModule.play_attack_animation(attack_type,weapon)
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

func _on_selection_area_mouse_entered() -> void:
	if drag_and_drop_component.dragging :
		return
	outline_highlight_component.highlight()
	z_index = 1

func _on_selection_area_mouse_exited() -> void:
	if drag_and_drop_component.dragging :
		return
	outline_highlight_component.clear_highlight()
	z_index = 0

func _on_drag_started()-> void:
	velocity_based_rotation_component.enabled = true

func _on_drag_canceled(starting_position: Vector2)-> void:
	reset_after_dragging(starting_position)

func reset_after_dragging(starting_position: Vector2) -> void:
	velocity_based_rotation_component.enabled = false
	global_position = starting_position


func _on_selection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.

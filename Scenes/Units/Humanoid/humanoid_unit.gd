extends Unit
class_name HumanoidUnit

@onready var animationPlayer = %AnimationPlayer
@onready var spriteModule: SpriteModule = %SpriteModule
@onready var statusEffectModule: StatusEffectModule = $StatusEffectModule
@onready var skillModule: SkillModule = $SkillModule
@onready var displayModule: DisplayModule = $DisplayModule
@onready var particleModule: ParticleModule = $ParticleModule
@onready var drag_and_drop_component: UnitDragAndDrop = %UnitDragAndDropComponent
@onready var velocity_based_rotation_component: VelocityBasedRotation = %VelocityBasedRotationComponent
@onready var outline_highlight_component: OutlineHighlighter = %OutlineHighlightComponent
@onready var state_machine: UnitStateMachine = $StateMachine
@onready var hurtbox_collision_shape: CollisionShape2D = %HurtboxCollisionShape
@onready var selection_area_collision_shape: CollisionShape2D = %SelectionAreaCollisionShape

@export var weapon_spritesheets: Dictionary = {
	Weapon.WeaponTypeEnum.UNARMED: PlaceholderTexture2D.new(),
}
@export var unit_size: float = 32.0

# State machine state overrides
var is_casting: bool:
	get: return state_machine.is_in_state(UnitState.CASTING)
var is_stunned: bool:
	get: return state_machine.is_in_state(UnitState.STUNNED)
var is_downed: bool:
	get: return state_machine.is_in_state(UnitState.DOWNED)

var is_action_locked: bool = false
var is_silenced: bool = false

# Movement
var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var previous_velocity: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var velocity_smoothing: float = 0.2
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 1000.0
var last_attack_time := 0.0
var deathmessagelist: Array[String] = ["DEAD", "OOF", "RIP", "OUCH", "BYE", ":(", "x_x"]


func _ready() -> void:
	super._ready()  # add_to_group("Live_Units")
	ensure_weapon()

	if not Engine.is_editor_hint():
		drag_and_drop_component.drag_started.connect(_on_drag_started)
		drag_and_drop_component.drag_canceled.connect(_on_drag_canceled)

	_setup_display_module()
	animationPlayer.animation_finished.connect(_on_anim_finished)
	stats.level_changed.connect(particleModule.emit_level_up_particles)
	spriteModule.update_sprites.call_deferred()

## Activation
func _on_activated() -> void:
	$StateMachine.process_mode = Node.PROCESS_MODE_PAUSABLE
	drag_and_drop_component.enabled = false
	velocity_based_rotation_component.enabled = false

func _on_deactivated() -> void:
	$StateMachine.process_mode = Node.PROCESS_MODE_DISABLED
	drag_and_drop_component.enabled = _is_player_unit()
	drag_and_drop_component.allowed_zones = _get_allowed_zones()
	velocity_based_rotation_component.enabled = true



func _is_player_unit() -> bool:
	if unit_data == null: return false
	if unit_data in Player.team: return true
	for u in Player.deployed_units:
		if is_instance_valid(u) and u.unit_data == unit_data: return true
	return false

func _get_allowed_zones() -> Array[Area2D]:
	var zone := get_tree().get_first_node_in_group("PlayerSpawnZone") as Area2D
	if zone: return [zone]
	printerr("No player spawn zone found in scene")
	return []


## Data
func apply_data(data: UnitData) -> void:
	super.apply_data(data)  # sets unit_data, team, stats, stats.setup_stats()
	if data.weapon: equip_weapon(data.weapon)
	elif data.default_weapon: equip_weapon(data.default_weapon)
	for a in data.accessories: equip_accessory(a)
	stats.recalculate_stats()
	_apply_skills.call_deferred(data.skill_list)

func save_changes_to_data() -> void:
	if unit_data == null:
		printerr("Cannot save changes to data, unit has no unit_data.")
		return
	unit_data.stats = stats
	unit_data.weapon = weapon
	unit_data.accessories = accessories.duplicate(true)

func _apply_skills(skills: Array[Skill]) -> void:
	if not is_node_ready(): await ready
	for skill in skillModule._active_skills: skill.detach(self)
	for skill in skillModule._passive_skills: skill.detach(self)
	skillModule._active_skills.clear()
	skillModule._passive_skills.clear()
	skillModule.skill_list.clear()
	for skill in skills: skillModule.add_skill(skill)


## Buff override
static func apply_buff(buff: Buff, unit: Unit) -> void:
	if unit == null: return
	match buff.domain:
		Buff.Domain.UNIT: unit.stats.add_buff(buff)
		Buff.Domain.WEAPON: if unit.weapon: unit.weapon.add_weapon_buff(buff)

static func remove_buff(buff: Buff, unit: Unit) -> void:
	if unit == null: return
	match buff.domain:
		Buff.Domain.UNIT: unit.stats.remove_buff(buff)
		Buff.Domain.WEAPON: if unit.weapon: unit.weapon.remove_weapon_buff(buff)


## Combat
func apply_stun(duration: float) -> void:
	state_machine._transition_to_next_state(UnitState.STUNNED, {"duration": duration})
	
func take_damage(incoming_damage: float, _damage_type: HitData.DamageType = HitData.DamageType.NONE, _hit_owner: Unit = null) -> void:
	incoming_damage += stats.current_damage_taken_bonus
	incoming_damage *= stats.current_damage_taken_multiplier
	incoming_damage = round(incoming_damage * pow(10.0, 2)) / pow(10.0, 2)

	if stats.shield > 0.0 and stats.shield > incoming_damage:
		stats.shield -= incoming_damage
		%DamagePopupMarker.damage_popup(str(incoming_damage), 0.5 + 0.01 * incoming_damage, Color(0.6, 0.8, 0.8, 1.0))
	elif stats.shield > 0.0 and stats.shield < incoming_damage:
		incoming_damage -= stats.shield
		%DamagePopupMarker.damage_popup(str(incoming_damage), 0.5 + 0.01 * incoming_damage, Color(0.6, 0.8, 0.8, 1.0))
		stats.shield = 0.0
		stats.health -= incoming_damage
		%DamagePopupMarker.damage_popup(str(incoming_damage), 0.75 + 0.01 * incoming_damage, Color(1, 1 - incoming_damage * 0.02, 1 - incoming_damage * 0.02))
	else:
		stats.health -= incoming_damage
		%DamagePopupMarker.damage_popup(str(incoming_damage), 0.75 + 0.01 * incoming_damage, Color(1, 1 - incoming_damage * 0.02, 1 - incoming_damage * 0.02))

func resolve_hit(hit_result: HitData) -> void:
	last_hit_owner = hit_result.hit_owner
	var not_locked := not state_machine.is_in_state(UnitState.CASTING) and not state_machine.is_in_state(UnitState.STUNNED)

	if randf_range(0.0, 100.0) <= stats.current_dodge_probability and not_locked:
		hit_result.outcome = HitData.HitOutcome.DODGE
		_dodge(hit_result)
	elif randf_range(0.0, 100.0) <= stats.current_parry_probability and not_locked:
		hit_result.outcome = HitData.HitOutcome.PARRY
		_parry(hit_result)
	elif randf_range(0.0, 100.0) <= stats.current_block_probability and not_locked:
		hit_result.outcome = HitData.HitOutcome.BLOCK
		_block(hit_result)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2.ZERO:
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force / 2)
		for passive in hit_result.hit_owner.weapon.onHitPassives:
			passive.on_hit(hit_result)
		hit_received.emit(hit_result)
	else:
		hit_result.outcome = HitData.HitOutcome.HIT
		skillModule.interrupt_active_skills("hit")
		take_damage(hit_result.base_damage, hit_result.damage_type, hit_result.hit_owner)
		_apply_passives(hit_result)
		for effect in hit_result.status_effects:
			statusEffectModule.apply_status_effect(effect)
		if hit_result.knockback_force >= 0.1 and hit_result.knockback_direction != Vector2.ZERO:
			apply_knockback(self, hit_result.knockback_direction, hit_result.knockback_force)
		var attacker_weapon: Weapon = hit_result.hit_owner.weapon if hit_result.hit_owner.has_method("equip_weapon") else null
		if attacker_weapon and attacker_weapon.weaponType != Weapon.WeaponTypeEnum.UNARMED:
			particleModule.emit_hit_particles()
		hit_received.emit(hit_result)

func _block(hit: HitData) -> void:
	spriteModule.play_block()
	var flat := maxf(hit.base_damage - stats.current_flat_block_power, 0.0)
	var blocked := flat - (flat / 100.0) * stats.current_percent_block_power
	%DamagePopupMarker.damage_popup("Blocked!", 0.5, Color("LightBlue"))
	take_damage(blocked, hit.damage_type, hit.hit_owner)
	var attacker_weapon: Weapon = hit.hit_owner.weapon if hit.hit_owner.has_method("equip_weapon") else null
	if attacker_weapon and attacker_weapon.weaponType != Weapon.WeaponTypeEnum.UNARMED \
			and weapon and weapon.weaponType != Weapon.WeaponTypeEnum.UNARMED:
		particleModule.emit_block_particles()

func _parry(hit: HitData) -> void:
	spriteModule.play_parry()
	%DamagePopupMarker.damage_popup("Parry!", 1.0, Color("Gold"))
	var attacker_weapon: Weapon = hit.hit_owner.weapon if hit.hit_owner.has_method("equip_weapon") else null
	if attacker_weapon and attacker_weapon.weaponType != Weapon.WeaponTypeEnum.UNARMED \
			and weapon and weapon.weaponType != Weapon.WeaponTypeEnum.UNARMED:
		particleModule.emit_parry_particles()

func _dodge(_hit: HitData) -> void:
	spriteModule.play_dodge()
	apply_knockback(self, Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)), 250.0)

func _apply_passives(hit_result: HitData) -> void:
	for passive in hit_result.hit_owner.weapon.onHitPassives:
		if _passive_clears_outcome(passive, hit_result.outcome):
			passive.on_hit(hit_result)

func _passive_clears_outcome(passive: OnHitPassive, outcome: HitData.HitOutcome) -> bool:
	match outcome:
		HitData.HitOutcome.DODGE: return passive.triggers_on_dodge
		HitData.HitOutcome.BLOCK: return passive.triggers_on_block
		HitData.HitOutcome.PARRY: return passive.triggers_on_parry
		_: return true

func get_downed() -> void:
	if is_instance_valid(last_hit_owner):
		last_hit_owner.stats.experience += stats.get_exp_worth()
		print("%s gave %s exp to %s" % [unit_name, stats.get_exp_worth(), last_hit_owner.unit_name])
	%DamagePopupMarker.damage_popup(deathmessagelist.pick_random(), 1.25, Color("DARKRED"), 0.25)
	var dir := (last_hit_owner.global_position - global_position).normalized()
	state_machine._transition_to_next_state(UnitState.DOWNED, {"dir_mult": 1 if dir.x < 0.0 else -1})
	unit_downed.emit(self, last_hit_owner)

func die() -> void:
	if is_instance_valid(last_hit_owner):
		last_hit_owner.stats.experience += stats.get_exp_worth()
		print("%s gave %s exp to %s" % [unit_name, stats.get_exp_worth(), last_hit_owner.unit_name])
	%DamagePopupMarker.damage_popup(deathmessagelist.pick_random(), 1.25, Color("DARKRED"), 0.25)
	unit_died.emit(self, last_hit_owner)
	queue_free()


## Weapon
func can_hit() -> bool:
	return weapon != null and last_attack_time >= 1.0 / weapon.current_attack_speed

func attack(target: Node2D) -> void:
	if is_action_locked: return
	var hit := HitData.new(owner)
	hit.is_critical = randf() <= stats.current_crit_chance / 100.0
	hit.crit_mult = stats.current_crit_damage
	hit.knockback_direction = (target.global_position - global_position).normalized()
	hit.hit_owner = self
	weapon.hit(target, hit)

func ensure_weapon() -> void:
	if weapon == null:
		if default_weapon != null: equip_weapon(default_weapon.duplicate(true))
		else: printerr("No weapon or default_weapon set for " + str(self))

func equip(_item: Item = null) -> void:
	if _item == null: return
	match _item.get_script().get_global_name():
		"Weapon", "RangedWeapon": equip_weapon(_item)
		"Accessory": equip_accessory(_item)
		_: printerr("Unknown item class '%s' for %s" % [_item.get_script().get_global_name(), _item.item_name])
	stats.recalculate_stats()

func equip_weapon(_wep: Weapon = null) -> void:
	if _wep == null: _wep = default_weapon

	if weapon and weapon.attack_performed.is_connected(_on_weapon_attack):
		weapon.remove_owner_buffs(stats)
		weapon.clear_weapon_buffs()
		weapon.attack_performed.disconnect(_on_weapon_attack)
		stats.changed.disconnect(weapon._on_owner_stats_change)

	if _wep:
		weapon = _wep.duplicate(true)
		weapon.owner = self
		weapon.setup_stats()
		weapon.apply_owner_buffs(stats)
		stats.changed.connect(weapon._on_owner_stats_change)
		weapon.attack_performed.connect(_on_weapon_attack)
		if spriteModule: spriteModule.update_sprites.call_deferred()
		weapon_changed.emit(weapon)


## Accessories
func equip_accessory(_acc: Accessory = null) -> void:
	if _acc == null: return
	if accessories.size() >= stats.current_accessory_limit:
		printerr("No free accessory slots for " + unit_name)
		return
	var acc := _acc.duplicate(true)
	acc.owner = self
	acc.apply_owner_buffs(stats)
	accessories.append(acc)
	accessories_changed.emit(accessories)

func unequip_accessory(_acc: Accessory) -> void:
	if _acc not in accessories:
		printerr("Accessory not equipped: " + _acc.item_name)
		return
	_acc.remove_owner_buffs(stats)
	accessories.erase(_acc)

func unequip_accessory_at(index: int) -> void:
	if index >= accessories.size(): return
	accessories[index].remove_owner_buffs(stats)
	accessories.remove_at(index)

func has_free_accessory_slot() -> bool:
	return accessories.size() < stats.current_accessory_limit

func get_accessory_at(index: int) -> Accessory:
	if index >= accessories.size(): return null
	return accessories[index]


## Targeting
func predict_position(time_ahead: float) -> Vector2:
	var _predicted_velocity := (velocity + acceleration * time_ahead).limit_length(stats.current_movement_speed * 1.5)
	return global_position + velocity * time_ahead + 0.5 * acceleration * time_ahead

func _smooth_velocity(new_vel: Vector2) -> void:
	velocity = velocity.lerp(new_vel, velocity_smoothing)

func get_units_in_group(group_name: String) -> Array:
	return get_tree().get_nodes_in_group(group_name)

func get_closest_unit(units: Array, max_distance := INF, filter: Callable = Callable()) -> Node2D:
	var closest: Node2D = null
	var closest_dist := max_distance
	for other in units:
		if other == self: continue
		if filter.is_valid() and not filter.call(other): continue
		var dist := position.distance_to(other.position)
		if dist < closest_dist:
			closest_dist = dist
			closest = other
	return closest

func get_target_position_vector(target_position := Vector2()) -> Vector2:
	return target_position - position

func position_proximity_check(target_position: Vector2, max_distance: float) -> bool:
	return position.distance_to(target_position) <= max_distance

func target_proximity_check(target: Node2D, max_distance: float) -> bool:
	return target != null and position.distance_to(target.position) <= max_distance

func melee_close_range_check(target: Node2D) -> bool:
	return weapon != null and target != null \
		and position.distance_to(target.position) <= max(50, weapon.current_attack_range / 1.3)

func melee_range_check(target: Node2D) -> bool:
	return weapon != null and target != null \
		and position.distance_to(target.position) <= max(50, weapon.current_attack_range)

func apply_knockback(target: Node2D, direction: Vector2, force: float) -> void:
	if target.has_method("receive_knockback"):
		target.receive_knockback(direction.normalized() * force)

func receive_knockback(force: Vector2) -> void:
	knockback_velocity += force


# --- Draw system ---

func auto_select_draw(draw_type: DrawSchedule.DrawType) -> void:
	var pool := CardPoolGenerator.generate_pool(self, draw_type, 3)
	if pool.is_empty(): return
	apply_draw(_pick_draw(pool))

func _pick_draw(pool: Array[LevelupCardData]) -> LevelupCardData:
	return pool.pick_random()

func apply_draw(card_data: LevelupCardData) -> void:
	match card_data.card_type:
		LevelupCardData.CardType.ACTIVE_SKILL, LevelupCardData.CardType.PASSIVE_SKILL:
			if card_data.skill: skillModule.add_skill(card_data.skill)
		LevelupCardData.CardType.STAT_BONUS:
			if card_data.stat_buff:
				stats.add_buff(card_data.stat_buff.duplicate(true))
				stats.recalculate_stats()

func process_pending_draws() -> void:
	pass


# --- Display ---

func _setup_display_module() -> void:
	%NameLabel.text = unit_name
	%NameLabel.visible = show_name
	if team != null and team.flagVisible:
		var flag := (preload("res://Scenes/flag.tscn") as PackedScene).instantiate()
		flag.position.y -= 80
		flag.modulate = team.team_color
		add_child(flag)
	displayModule.set_healthbar_visibility(show_health)
	if show_health:
		displayModule.update_healthBar(stats.health, stats.current_max_health)
		stats.connect("health_changed", displayModule.update_healthBar)
		stats.connect("shield_changed", displayModule.update_shieldBar)
		stats.connect("shield_depleted", displayModule.hide_shieldBar)
	stats.connect("health_depleted", get_downed)
	displayModule.link_to_unit(self)


# --- Input / selection ---

func _on_selection_area_mouse_entered() -> void:
	if drag_and_drop_component.dragging: return
	outline_highlight_component.highlight()
	z_index = 1

func _on_selection_area_mouse_exited() -> void:
	if drag_and_drop_component.dragging: return
	outline_highlight_component.clear_highlight()
	z_index = 0

func _on_drag_started() -> void:
	velocity_based_rotation_component.enabled = true

func _on_drag_canceled(starting_position: Vector2) -> void:
	reset_after_dragging(starting_position)

func reset_after_dragging(starting_position: Vector2) -> void:
	velocity_based_rotation_component.enabled = false
	global_position = starting_position

func _on_selection_area_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT: unit_clicked.emit(self)
		if _event.button_index == MOUSE_BUTTON_RIGHT: Inspector.open(self)


# --- Internal callbacks ---

func _on_anim_finished(_anim_name) -> void:
	is_action_locked = false

func _on_weapon_attack(_damage_type: HitData.DamageType, _endlag: float = 0.0) -> void:
	spriteModule.play_attack()
	is_action_locked = true

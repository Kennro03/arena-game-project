extends Node
class_name BattleManager

signal BeginEncounter
signal WonEncounter
signal LostEncounter

var ennemy_units_alive : Array[BaseUnit]
var neutral_units_alive : Array[BaseUnit]
var player_units_alive : Array[BaseUnit]

enum LevelState { LOADING, SPAWNING, FIGHTING, RESOLVING, COMPLETE }

@export var spawner : EncounterSpawner
@export var level_data: BattleData
@export var player_units: Array[UnitData] = []
@export var enemy_units : Array[EnemyData] = []

var state: LevelState = LevelState.LOADING

@onready var UI_node : Control = %EncounterUI
@onready var player_zone : Area2D = %PlayerZone
@onready var neutral_zone : Area2D = %NeutralZone
@onready var enemy_zone : Area2D = %EnemyZone
@onready var selection_manager: SelectionManager = %SelectionManager


func _ready() -> void:
	UI_node.connect("StartEncounterPressed",start_fight)
	BeginEncounter.connect(UI_node._on_begin_encounter)
	WonEncounter.connect(UI_node._on_won_encounter)
	LostEncounter.connect(UI_node._on_lost_encounter)
	Events.slot_drag_ended.connect(_on_slot_drag_ended)
	Events.unit_recalled.connect(_on_unit_recalled)
	
	load_level_data(level_data)
	
	#print("level data = " + str(level_data))
	#print("level data forced ennemies = " + str(level_data.forced_enemies))
	#print("level data pool = " + str(level_data.random_enemy_pool))

static func get_instance(node: Node) -> BattleManager:
	var managers := node.get_tree().get_nodes_in_group("BattleManager")
	return managers[0] as BattleManager if not managers.is_empty() else null

static func get_state(node: Node) -> LevelState:
	var manager := get_instance(node)
	return manager.state if manager else LevelState.COMPLETE

func load_level_data(data: BattleData) -> void:
	print("Loading...")
	state = LevelState.LOADING
	level_data = data
	player_units += Player.team
	print("Player units = [")
	for u in player_units :
		print("	%s" % [u.display_name])
	print("]")
	#_apply_modifiers()
	spawn_units()

func spawn_units() ->void : 
	print("Spawning units...")
	state = LevelState.SPAWNING
	_spawn_player_units.call_deferred()
	_spawn_enemy_units.call_deferred()

func start_fight() ->void : 
	if state == LevelState.SPAWNING :
		#print("Allies : " + str(players_alive) + "\nEnnemies : " + str(enemies_alive))
		print("Starting fight...")
		state = LevelState.FIGHTING
		emit_signal("BeginEncounter")
		await UI_node.introEnded
		for unit in %Units.get_children() :
			unit.active = true

func _spawn_player_units() -> void:
	print("Spawning player units...")
	for unit_data in player_units:
		var unit := spawner.spawn_from_data(spawner._random_point_in_zone(player_zone),unit_data)
		if unit:
			Player.register_deployed_unit(unit)
			player_units_alive.append(unit)
			unit.stats.health_depleted.connect(_on_player_unit_died.bind(unit))
			selection_manager.register_unit(unit)

func _spawn_enemy_units() -> void:
	print("Spawning enemy units...")
	enemy_units = _generate_enemy_list()
	
	for enemy_data in enemy_units:
		enemy_data.unit_data.team = preload("res://ressources/Teams/EnemyTeam.tres")  # Set enemy unit team to consistent team
		var unit := spawner.spawn_from_data(spawner._random_point_in_zone(enemy_zone), enemy_data.unit_data)
		if unit:
			ennemy_units_alive.append(unit)
			unit.stats.health_depleted.connect(_on_enemy_unit_died.bind(unit))
			selection_manager.register_unit(unit)

func _generate_enemy_list() -> Array[EnemyData]:
	var enemies_array: Array[EnemyData] = level_data.forced_enemies
	var budget := level_data.enemy_force  # "points" to spend
	#print("Budget = " + str(budget))
	var pool := level_data.random_enemy_pool
	
	print("Enemy pool = [")
	for e in pool :
		print("	%s" % [e.unit_data.display_name])
	print("]")
	
	print("Forced ennemies = [")
	for e in level_data.forced_enemies :
		print("	%s" % [e.unit_data.display_name])
	print("]")
	
	if enemies_array == [] and pool.size() <= 0 : 
		printerr("No forced enemies and enemy pool to pull from !")
		return []
	
	#print("getting cost of forced ennemies")
	for forced_enemy in enemies_array :
		budget-= forced_enemy.get_cost()
	
	var attempts : int = 0
	var max_attempts : int = 50  
	while budget > 0 and attempts < max_attempts :
		
		var affordable : Array[EnemyData] = pool.filter(func(e): return e.base_cost <= budget)
		#print("Attempt n°" + str(attempts) + ", affordable enemies : " + str(affordable))
		if affordable.is_empty() : 
			#print("No affordable ennemies, exiting loop.")
			attempts += max_attempts
		else : 
			var candidate: EnemyData = affordable.pick_random()
			#print("Selected candidate : " + str(candidate.unit_data.display_name))
			#var modified := candidate.with_random_modifiers(randi() % level_data.max_enemy_modifiers + 1) as EnemyData
			#print("getting final cost")
			var final_cost : float = candidate.get_cost()
			if final_cost <= budget:
				enemies_array.append(candidate)
				budget -= final_cost
		attempts += 1
	
	print("Ennemies = [")
	for e in enemies_array :
		print("	%s" % [e.unit_data.display_name])
	print("]")
	return enemies_array

func _on_slot_drag_ended(slot: Slot, world_pos: Vector2) -> void:
	if slot is UnitSlot and slot._unit_data != null:
		_try_deploy_unit(slot._unit_data, world_pos)
	if slot is ItemSlot and slot.item != null :
		_try_equip_item(slot.item,world_pos)

func _try_equip_item(item: Item, world_pos: Vector2) -> void:
	# check if dropped on a deployed unit
	var target_unit := _get_unit_at_position(world_pos)
	if target_unit and target_unit in Player.deployed_units :
		if item is Weapon and target_unit.weapon.item_id != target_unit.default_weapon.item_id :
			Player.add_item_to_inventory(target_unit.weapon)
		if item is Armor and target_unit.armor != null :
			Player.add_item_to_inventory(target_unit.armor)
		if item is Accessory and target_unit.accessories.size() == target_unit.stats.current_accessory_limit :
			return
			## !!! Need special logic to determine which accessories to replace
		target_unit.equip(item)
		Player.remove_item_from_inventory(item)

func _try_deploy_unit(data: UnitData, world_pos: Vector2) -> void:
	#if not _is_in_player_zone(world_pos):
		#return
	
	if state != LevelState.SPAWNING :
		Events.unit_deployment_failed.emit("Cannot deploy outside of deployment phase")
		return
	
	if Player.team.size() >= Player.team_size:
		Events.unit_deployment_failed.emit("Team is full")
		return
	
	if is_in_zone(player_zone,get_world_mouse_position()) != true :
		printerr("Can't deploy unit outside of player zone")
		Events.unit_deployment_failed.emit("Cursor not in player zone")
		return
	
	Player.move_unit_to_team(data)
	var deployed_unit := spawner.spawn_from_data(world_pos, data)
	Player.register_deployed_unit(deployed_unit)
	player_units_alive.append(deployed_unit)
	deployed_unit.stats.health_depleted.connect(_on_player_unit_died.bind(deployed_unit))
	#print("Player units : " + str(player_units_alive))
	Events.unit_deployed.emit(data)

func is_in_zone(zone: Area2D, world_pos: Vector2) -> bool:
	var col := zone.get_node("CollisionShape2D") as CollisionShape2D
	if col == null:
		return false
	var shape := col.shape as RectangleShape2D
	if shape == null:
		printerr("no shape defined for zone " + str(zone))
		return false
	var rect := Rect2(col.global_position - shape.size / 2.0, shape.size)
	return rect.has_point(world_pos)

func get_world_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

func is_mouse_in_player_zone() -> bool:
	return is_in_zone(player_zone, get_world_mouse_position())

func is_mouse_in_neutral_zone() -> bool:
	return is_in_zone(neutral_zone, get_world_mouse_position())

func is_mouse_in_ennemy_zone() -> bool:
	return is_in_zone(enemy_zone, get_world_mouse_position())

func _on_exit_battle(_victory: bool) -> void:
	print("Leaving battle...")
	Player.clear_deployed_units()

func _get_unit_at_position(world_pos: Vector2) -> BaseUnit :
	var space := get_viewport().world_2d.direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := space.intersect_point(query)
	for result in results:
		var parent : Node = result.collider.get_parent()
		if parent is BaseUnit:
			return parent
	return null

func _on_unit_recalled(unit: BaseUnit) -> void:
	player_units_alive.erase(unit)
	#print("Player unit recalled, remaining: %d" % player_units_alive.size())
	if player_units_alive.is_empty() and state == LevelState.FIGHTING:
		state = LevelState.RESOLVING
		LostEncounter.emit()

func _on_enemy_unit_died(unit: BaseUnit) -> void:
	ennemy_units_alive.erase(unit)
	#print("Enemies remaining = " + str(ennemy_units_alive.size()))
	_check_victory_conditions()

func _on_player_unit_died(unit: BaseUnit) -> void:
	player_units_alive.erase(unit)
	#print("Allies remaining = " + str(player_units_alive.size()))
	_check_victory_conditions()

func _check_victory_conditions() -> void:
	# clean up any stale references first
	player_units_alive = player_units_alive.filter(func(u): return is_instance_valid(u))
	ennemy_units_alive = ennemy_units_alive.filter(func(u): return is_instance_valid(u))
	if ennemy_units_alive.is_empty():
		state = LevelState.RESOLVING
		WonEncounter.emit()
	elif player_units_alive.is_empty():
		state = LevelState.RESOLVING
		LostEncounter.emit()

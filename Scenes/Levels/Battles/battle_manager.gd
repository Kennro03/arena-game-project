extends Node
class_name BattleManager

signal BeginEncounter
signal WonEncounter
signal LostEncounter

var enemies_alive : int = 0
var players_alive : int = 0

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
	print("level data = " + str(level_data))
	print("level data forced ennemies = " + str(level_data.forced_enemies))
	print("level data pool = " + str(level_data.random_enemy_pool))
	load_level_data(level_data)

func _process(_delta: float) -> void:
	pass

func load_level_data(data: BattleData) -> void:
	print("Loading...")
	state = LevelState.LOADING
	level_data = data
	player_units += Player.team
	print("player units : " + str(player_units))
	#_apply_modifiers()
	spawn_units()

func spawn_units() ->void : 
	print("Spawning units...")
	state = LevelState.SPAWNING
	_spawn_player_units.call_deferred()
	_spawn_enemy_units.call_deferred()

func start_fight() ->void : 
	if state == LevelState.SPAWNING :
		print("Starting fight...")
		state = LevelState.FIGHTING
		emit_signal("BeginEncounter")
		await UI_node.introEnded
		for unit in %Units.get_children() :
			unit.active = true

func _spawn_player_units() -> void:
	print("Spawning player units...")
	for unit_data in player_units:
		var unit := spawner.spawn_from_data(spawner._random_point_in_zone(player_zone), unit_data,load("res://ressources/Teams/PlayerTeam.tres"))
		if unit:
			players_alive += 1
			unit.stats.health_depleted.connect(_on_player_unit_died)
			selection_manager.register_unit(unit)

func _spawn_enemy_units() -> void:
	print("Spawning enemy units...")
	enemy_units = _generate_enemy_list()
	
	for enemy_data in enemy_units:
		var unit := spawner.spawn_from_data(spawner._random_point_in_zone(enemy_zone), enemy_data.unit_data)
		if unit:
			enemies_alive += 1
			unit.stats.health_depleted.connect(_on_enemy_unit_died)
			selection_manager.register_unit(unit)

func _generate_enemy_list() -> Array[EnemyData]:
	var enemies_array: Array[EnemyData] = level_data.forced_enemies
	var budget := level_data.enemy_force  # "points" to spend
	print("Budget = " + str(budget))
	var pool := level_data.random_enemy_pool
	#print("Pool = " + str(pool))
	
	if enemies_array == [] and pool.size() <= 0 : 
		printerr("No forced enemies and enemy pool to pull from !")
		return []
	
	print("getting cost of forced ennemies")
	for forced_enemy in enemies_array :
		budget-= forced_enemy.get_cost()
	
	var attempts : int = 0
	var max_attempts : int = 50  
	while budget > 0 and attempts < max_attempts :
		
		var affordable : Array[EnemyData] = pool.filter(func(e): return e.base_cost <= budget)
		print("Attempt n°" + str(attempts) + ", affordable enemies : " + str(affordable))
		if affordable.is_empty() : 
			print("No affordable ennemies, exiting loop.")
			attempts += max_attempts
		else : 
			var candidate: EnemyData = affordable.pick_random()
			print("Selected candidate : " + str(candidate.unit_data.display_name))
			#var modified := candidate.with_random_modifiers(randi() % level_data.max_enemy_modifiers + 1) as EnemyData
			print("getting final cost")
			var final_cost : float = candidate.get_cost()
			if final_cost <= budget:
				enemies_array.append(candidate)
				budget -= final_cost
		attempts += 1
	
	return enemies_array

func _on_enemy_unit_died() -> void:
	enemies_alive -= 1
	print("Enemies remaining = " + str(enemies_alive))
	if enemies_alive <= 0 :
		state = LevelState.RESOLVING
		print("Won fight")
		WonEncounter.emit()  # players win

func _on_player_unit_died() -> void:
	players_alive -= 1
	if players_alive <= 0 :
		state = LevelState.RESOLVING
		print("Lost fight")
		LostEncounter.emit()  # players lose

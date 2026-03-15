extends Node
class_name EncounterManager

signal BeginEncounter
signal WonEncounter
signal LostEncounter

var enemies_alive : int = 0
var players_alive : int = 0

enum LevelState { LOADING, SPAWNING, FIGHTING, RESOLVING, COMPLETE }

@export var spawner : EncounterSpawner
@export var level_data: LevelData
@export var player_units: Array[UnitData] = []
@export var enemy_units : Array[EnemyData] = []

var state: LevelState = LevelState.LOADING


@onready var UI_node : Control = %EncounterUI
@onready var player_zone : Area2D = %PlayerZone
@onready var neutral_zone : Area2D = %NeutralZone
@onready var enemy_zone : Area2D = %EnemyZone


func _ready() -> void:
	UI_node.connect("StartEncounterPressed",start_fight)
	BeginEncounter.connect(UI_node._on_begin_encounter)
	WonEncounter.connect(UI_node._on_won_encounter)
	LostEncounter.connect(UI_node._on_lost_encounter)
	load_level(level_data,player_units)

func _process(_delta: float) -> void:
	pass

func load_level(data: LevelData, units: Array[UnitData]) -> void:
	print("Loading...")
	state = LevelState.LOADING
	level_data = data
	player_units = units
	#_apply_modifiers()
	spawn_units.call_deferred()

func spawn_units() ->void : 
	print("Spawning units...")
	state = LevelState.SPAWNING
	_spawn_player_units()
	_spawn_enemy_units()

func start_fight() ->void : 
	if state == LevelState.SPAWNING :
		print("Starting fight...")
		state = LevelState.FIGHTING
		emit_signal("BeginEncounter")
		await UI_node.introEnded
		for unit in %Units.get_children() :
			unit.active = true
	pass

func _spawn_player_units() -> void:
	for unit_data in player_units:
		var unit := spawner.spawn_from_data(spawner._random_point_in_zone(player_zone), unit_data,load("res://ressources/Teams/PlayerTeam.tres"))
		if unit:
			players_alive += 1
			unit.stats.health_depleted.connect(_on_player_unit_died)

func _spawn_enemy_units() -> void:
	if enemy_units == [] :
		enemy_units = _generate_enemy_list()
	for enemy_data in enemy_units:
		var unit := spawner.spawn_from_data(spawner._random_point_in_zone(enemy_zone), enemy_data.unit_data)
		if unit:
			enemies_alive += 1
			unit.stats.health_depleted.connect(_on_enemy_unit_died)

func _generate_enemy_list() -> Array[EnemyData]:
	var enemies_array: Array[EnemyData] = [] 
	var budget := level_data.enemy_force  # "points" to spend
	print("Budget = " + str(budget))
	var pool := level_data.enemy_pool
	print("Pool = " + str(pool))
	
	if pool.size() <= 0 : 
		printerr("No enemy pool to pull from !")
		return []
	
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
			var final_cost : float = candidate.get_cost()
			if final_cost <= budget:
				enemies_array.append(candidate)
				budget -= final_cost
		attempts += 1
	
	print(str(enemies_array))
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

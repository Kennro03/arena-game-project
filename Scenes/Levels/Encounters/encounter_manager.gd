extends Node
class_name EncounterManager

enum LevelState { LOADING, SPAWNING, FIGHTING, RESOLVING, COMPLETE }

@export var level_data: LevelData
var player_units: Array[UnitData] = []
var state: LevelState = LevelState.LOADING

@export var spawner : EncounterSpawner

@onready var UI_node : Control = %EncounterUI
@onready var player_zone : Area2D = %PlayerZone
@onready var neutral_zone : Area2D = %NeutralZone
@onready var enemy_zone : Area2D = %EnemyZone

func _ready() -> void:
	UI_node.connect("StartEncounterPressed",start_fight)
	load_level(level_data,[])

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
		UI_node.emit_signal("BeginFight")
		for unit in %Units.get_children() :
			unit.active = true
	pass

func _spawn_player_units() -> void:
	for unit_data in player_units:
		spawner.spawn_from_data(spawner._random_point_in_zone(player_zone), unit_data)

func _spawn_enemy_units() -> void:
	var enemies : Array[EnemyData] = _generate_enemy_list()
	for enemy_data in enemies:
		spawner.spawn_from_data(spawner._random_point_in_zone(enemy_zone), enemy_data.unit_data)

func _generate_enemy_list() -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []
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
				enemies.append(candidate)
				budget -= final_cost
		attempts += 1
	
	print(str(enemies))
	return enemies

func _watch_for_completion() -> void:
	# poll or use signals to detect when all enemies or all players are dead
	pass

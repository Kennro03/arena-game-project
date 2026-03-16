extends Resource
class_name EncounterData

@export_group("Encounter data")
@export var enemy_force: float = 1.0        # multiplier for enemy strength/count
@export var forced_enemies: Array[EnemyData] = [] # enemies that are guaranteed to spawn
@export var random_enemy_pool: Array[EnemyData] = [] # which enemies can spawn
@export var modifiers: Array[String] = [] # WIP, not implemeted
@export var map_type: String = "default"

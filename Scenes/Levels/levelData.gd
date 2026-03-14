extends Resource
class_name LevelData

enum LevelType { NORMAL, ELITE, BOSS, AMBUSH, SHOP, EVENT }

@export var level_type: LevelType = LevelType.NORMAL
@export var enemy_force: float = 1.0        # multiplier for enemy strength/count
@export var enemy_pool: Array[EnemyData] = [] # which enemies can spawn
@export var modifiers: Array[String] = [] # WIP, not implemeted
@export var map_type: String = "default"

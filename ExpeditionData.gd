extends Resource
class_name ExpeditionData

@export var ExpeditionName : String = ""
@export var ExpeditionDescription : String = ""
@export var ExpeditionIcon : Texture2D

@export var ShopItemPool : Array[Item] = []
@export var EventPool : Array[EventResource] = []
@export var EnemyPool : Array[EnemyData] = []
@export var ElitePool : Array[EnemyData] = []
@export var BossPool : Array[EnemyData] = []
@export var BaseEnemyScore : float = 10.0
@export var FloorEnemyScoreScaling : float = 3.0

var CombatMapPool #Not implemented
var MapBackground #Not implemented

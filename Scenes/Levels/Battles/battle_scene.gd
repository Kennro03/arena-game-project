extends Node2D
class_name BattleScene

@export var battle_manager: BattleManager
@export var battle_spawner: BattleSpawner

@onready var ui: CanvasLayer = %UI

func _ready() -> void:
	Player.ui_layer = ui

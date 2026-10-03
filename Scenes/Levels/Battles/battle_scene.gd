extends Node2D
class_name BattleScene

@export var battle_manager: BattleManager
@export var battle_spawner: BattleSpawner

@onready var ui: CanvasLayer = %UI
@onready var overlay_ui: CanvasLayer = %OverlayUI


func _ready() -> void:
	Player.ui_layer = ui
	Player.overlay_layer = overlay_ui
	
	var data := Player.pending_battle
	Player.pending_battle = null  # consume it so it doesn't bleed into the next battle
	
	if data == null:
		printerr("BattleScene: no BattleData provided")
		data = battle_manager.battle_data
	
	battle_manager.initialize_battle(data)

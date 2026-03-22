extends Node2D

@export var battle_scene : StringName = &"" 

func _ready() -> void:
	var pablo:stickmanUnitData = preload("res://Scenes/Levels/Battles/test_level/Pablo.tres").duplicate(true)
	Player.add_to_reserve(pablo)
	Player.add_to_team(pablo)

func _on_battle_button_pressed() -> void:
	SceneLoader.load_scene(battle_scene)

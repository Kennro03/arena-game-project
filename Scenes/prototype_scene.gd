extends Node2D

@export var battle_scene : StringName = &"" 

func _on_battle_button_pressed() -> void:
	SceneLoader.load_scene(battle_scene)

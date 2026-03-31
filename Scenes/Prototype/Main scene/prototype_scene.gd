extends Node2D

@export var battle_scene : StringName = &"" 
@export var shop_scene : StringName = &"" 

func _ready() -> void:
	pass

func _on_battle_button_pressed() -> void:
	SceneLoader.load_scene(battle_scene)

func _on_shop_button_pressed() -> void:
	SceneLoader.load_scene(shop_scene)

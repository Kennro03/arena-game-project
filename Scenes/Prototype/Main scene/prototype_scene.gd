extends Node2D

@export var battle_scene : StringName = &"" 
@export var shop_scene : StringName = &"" 

func _ready() -> void:
	Player.current_scene = "uid://hlb8w8j5gs7u"

func _on_battle_button_pressed() -> void:
	Player.go_to_scene(battle_scene)

func _on_shop_button_pressed() -> void:
	Player.go_to_scene(shop_scene)

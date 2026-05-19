extends Node2D

@onready var ui: CanvasLayer = %UI

@export var battle_scene : StringName = &"" 
@export var shop_scene : StringName = &"" 
@export var event_scene : StringName = &""
@export var expedition_scene : StringName = &""
@export var camp_scene : StringName = &""

func _ready() -> void:
	Player.current_scene = "uid://hlb8w8j5gs7u"
	Player.ui_layer = ui

func _on_expedition_button_pressed() -> void:
	Player.go_to_scene(expedition_scene)

func _on_battle_button_pressed() -> void:
	var data := BattleData.new()
	data.forced_enemies = [
		preload("res://ressources/Units/enemy_data/LittleGuy.tres"),
		preload("res://ressources/Units/enemy_data/LittleGuy.tres"),
		preload("res://ressources/Units/enemy_data/LittleGuy.tres")]
	Player.pending_battle = data
	Player.go_to_scene(battle_scene)

func _on_shop_button_pressed() -> void:
	Player.go_to_scene(shop_scene)

func _on_event_button_pressed() -> void:
	Player.go_to_scene(event_scene)

func _on_camp_button_pressed() -> void:
	Player.go_to_scene(camp_scene)

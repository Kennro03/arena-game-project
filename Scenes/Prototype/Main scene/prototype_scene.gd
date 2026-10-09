extends Node2D

const ARENA_SETUP = preload("uid://cbbr1vp20iks7")
const FIGHTER_GENERATION_SCENE = preload("uid://c154o53mrj6im")
const ARENA_CIRCUIT = preload("uid://clh70vlg1drhg")

@export var expedition_selection_scene : StringName = &""
@export var expedition_scene : StringName = &""
@export var battle_scene : StringName = &"" 
@export var shop_scene : StringName = &"" 
@export var event_scene : StringName = &""
@export var camp_scene : StringName = &""

@onready var ui: CanvasLayer = %UI

func _ready() -> void:
	Player.current_scene = "uid://hlb8w8j5gs7u"
	Player.ui_layer = ui

func _on_expedition_button_pressed() -> void:
	Player.go_to_scene(expedition_selection_scene)

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

func _on_arena_gamemode_button_pressed() -> void:
	var arena_setup : ArenaSetupScene = ARENA_SETUP.instantiate()
	ui.add_child(arena_setup)
	#arena_setup.connect()

func spawn_fighter_generation_scene() -> void:
	var fighter_generation_scene : FighterGenerationScene = FIGHTER_GENERATION_SCENE.instantiate()
	ui.add_child(fighter_generation_scene)

func _on_tournament_gamemode_button_pressed() -> void:
	pass # Replace with function body.

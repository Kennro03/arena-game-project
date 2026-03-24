extends Node2D

@export var battle_scene : StringName = &"" 

@onready var ui: Control = %UI

const inventory_scene : PackedScene = preload("res://Scenes/UI/inventory/inventory.tscn")

var inventory_instance 

func _ready() -> void:
	var pablo:stickmanUnitData = preload("res://Scenes/Levels/Battles/test_level/Pablo.tres").duplicate(true)
	Player.add_to_reserve(pablo)
	Player.add_to_team(pablo)

func _on_battle_button_pressed() -> void:
	SceneLoader.load_scene(battle_scene)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Inventory") :
		toggle_inventory()

func toggle_inventory() -> void :
	var ui_children := ui.get_children()
	if not inventory_instance in ui_children :
		inventory_instance = inventory_scene.instantiate()
		ui.add_child(inventory_instance)
	else :
		inventory_instance.queue_free()
		inventory_instance = null

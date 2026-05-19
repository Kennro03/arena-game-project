extends Node
class_name InventoryReserveManager

@onready var ui: CanvasLayer = %UI

const inventory_UI_scene : PackedScene = preload("uid://qkugb2gfdcdn")
const reserve_UI_scene : PackedScene = preload("uid://buquhmksgk22a")
const team_UI_scene : PackedScene = preload("uid://wkm8slle2lka")

var inventory_position : Vector2 = Vector2(0.0,0.0)
var reserve_position : Vector2 = Vector2(0.0,0.0)

var inventory_UI_instance : Control
var reserve_UI_instance : Control
var team_UI_instance : Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Inventory") :
		if inventory_UI_instance :
			inventory_position = inventory_UI_instance.position
		inventory_UI_instance = toggle_scene_instance(inventory_UI_scene,inventory_UI_instance, inventory_position)
	if Input.is_action_just_pressed("Reserve") :
		if reserve_UI_instance :
			reserve_position = reserve_UI_instance.position
		reserve_UI_instance = toggle_scene_instance(reserve_UI_scene,reserve_UI_instance, reserve_position)
	if Input.is_action_just_pressed("Team") :
		team_UI_instance = toggle_scene_instance(team_UI_scene,team_UI_instance)

func toggle_scene_instance(scene : PackedScene, instance, window_position : Vector2 = Vector2(0.0,0.0)) -> Node :
	var _ui_children := ui.get_children()
	if is_instance_valid(instance) :
		instance.queue_free()
		instance = null
		return null
	else :
		var new_instance : Control = scene.instantiate()
		new_instance.position = window_position
		ui.add_child(new_instance)
		return new_instance

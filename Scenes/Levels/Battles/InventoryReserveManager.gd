extends Node
class_name InventoryReserveManager

@onready var ui: CanvasLayer = %UI

const inventory_UI_scene : PackedScene = preload("uid://qkugb2gfdcdn")
const reserve_UI_scene : PackedScene = preload("uid://buquhmksgk22a")
const team_UI_scene : PackedScene = preload("uid://wkm8slle2lka")

var inventory_UI_instance
var reserve_UI_instance
var team_UI_instance

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Inventory") :
		inventory_UI_instance = toggle_scene_instance(inventory_UI_scene,inventory_UI_instance)
	if Input.is_action_just_pressed("Reserve") :
		reserve_UI_instance = toggle_scene_instance(reserve_UI_scene,reserve_UI_instance)
	if Input.is_action_just_pressed("Team") :
		team_UI_instance = toggle_scene_instance(team_UI_scene,team_UI_instance)

func toggle_scene_instance(scene : PackedScene, instance) -> Node :
	var _ui_children := ui.get_children()
	if is_instance_valid(instance) :
		instance.queue_free()
		instance = null
		return null
	else :
		var new_instance := scene.instantiate()
		ui.add_child(new_instance)
		return new_instance

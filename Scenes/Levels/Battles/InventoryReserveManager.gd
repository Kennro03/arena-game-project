extends Node
class_name InventoryReserveManager

@onready var ui: CanvasLayer = %UI

const inventory_scene : PackedScene = preload("res://Scenes/UI/inventory/inventory.tscn")
const reserve_scene : PackedScene = preload("res://Scenes/UI/reserve/reserve.tscn")

var inventory_instance
var reserve_instance

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Inventory") :
		inventory_instance = toggle_scene_instance(inventory_scene,inventory_instance)
	if Input.is_action_just_pressed("Reserve") :
		reserve_instance = toggle_scene_instance(reserve_scene,reserve_instance)

func toggle_scene_instance(scene : PackedScene, instance) -> Node :
	var ui_children := ui.get_children()
	if is_instance_valid(instance) :
		instance.queue_free()
		instance = null
		return null
	else :
		var new_instance := scene.instantiate()
		ui.add_child(new_instance)
		return new_instance

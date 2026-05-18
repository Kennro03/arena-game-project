extends Node
class_name InspectionManager

const InspectMenuScene := preload("res://Scenes/UI/InspectMenu/inspect_menu.tscn")
var current_menu: InspectMenu = null
@export var ui_root: CanvasLayer

func open(target: Object) -> void:
	if ui_root == null:
		printerr("InspectionManager: no ui_root set")
		return
	close()  # close existing
	current_menu = InspectMenuScene.instantiate()
	current_menu.target = target
	ui_root.add_child(current_menu)

func close() -> void:
	if is_instance_valid(current_menu):
		current_menu.close()
	current_menu = null

extends Node
class_name InspectionManager

const InspectMenuScene := preload("res://Scenes/UI/InspectMenu/inspect_menu.tscn")
var current_menu: InspectMenu = null

func open(target: Object) -> void:
	if Player.ui_layer == null:
		printerr("Player : no ui_root reference found")
		return
	close()  # close existing
	current_menu = InspectMenuScene.instantiate()
	current_menu.target = target
	Player.ui_layer.add_child(current_menu)

func close() -> void:
	if is_instance_valid(current_menu):
		current_menu.close()
	current_menu = null

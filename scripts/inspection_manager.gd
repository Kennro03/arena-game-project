extends Node
class_name InspectionManager

const InspectMenuScene := preload("res://Scenes/UI/InspectMenu/inspect_menu.tscn")
var current_menu: InspectMenu = null
@export var ui_root: Control

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var target := _get_inspect_target()
			if target:
				open(target)
				get_viewport().set_input_as_handled()
			else:
				close()

func _get_inspect_target() -> Object:
	# check UI slots first (they're on top visually)
	var ui_target := _get_hovered_slot()
	if ui_target:
		return ui_target
	
	# then check 2D units via physics query
	var physics_target := _get_hovered_unit()
	if physics_target:
		return physics_target
	
	return null

func _get_hovered_slot() -> Control:
	# walk up from the hovered control to find a Slot
	var hovered := get_viewport().gui_get_hovered_control()
	while hovered != null:
		if hovered is Slot:
			return hovered
		hovered = hovered.get_parent() as Control
	return null

func _get_hovered_unit() -> BaseUnit:
	var space := get_viewport().world_2d.direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := space.intersect_point(query)
	
	for result in results:
		var parent : Node = result.collider.get_parent()
		if parent is BaseUnit:
			return parent
	return null

func open(target: Object) -> void:
	close()  # close existing
	current_menu = InspectMenuScene.instantiate()
	current_menu.target = target
	ui_root.add_child(current_menu)

func close() -> void:
	if is_instance_valid(current_menu):
		current_menu.close()
	current_menu = null

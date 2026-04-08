extends Node
class_name UnitDragAndDrop

signal drag_canceled(starting_position: Vector2)
signal drag_started
signal dropped(starting_position: Vector2)

@export var enabled: bool = true
@export var target_area: Node
@export var target: Node
@export var allowed_zones: Array[Area2D] = []  #if [], anywhere is valid

var starting_position: Vector2
var offset := Vector2.ZERO
var dragging := false
var original_z_index : int

func _ready() -> void: 
	assert(target, "No target set for DragAndDrop Component!")
	assert(target_area, "No target_area set for DragAndDrop Component!")
	if target_area is Area2D :
		#print("Area2D")
		target_area.input_event.connect(_on_target_input_event.unbind(1))
	elif target_area is Control :
		#print("Control")
		target_area.gui_input.connect(_on_target_gui_event)

func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset

func _end_dragging() -> void:
	dragging = false
	target.remove_from_group("dragging")
	target.z_index = original_z_index

func _cancel_dragging() -> void :
	_end_dragging()
	drag_canceled.emit(starting_position)

func _start_dragging() -> void: 
	dragging = true
	starting_position = target.global_position
	target.add_to_group("dragging")
	original_z_index = target.z_index
	target.z_index = 99
	offset = target.global_position - target.get_global_mouse_position()
	drag_started.emit()

func _drop() -> void:
	_end_dragging()
	var world_pos := _get_world_mouse_position()
	#print("Allowed zones : " + str(allowed_zones))
	if allowed_zones.is_empty() or _is_in_allowed_zone(world_pos):
		dropped.emit(starting_position)
		#print("Dropped in allowed zone")
	else:
		drag_canceled.emit(starting_position)
		#print("Dropped in unauthorized zone")

func _is_in_allowed_zone(world_pos: Vector2) -> bool:
	for zone in allowed_zones:
		var col := zone.get_node("CollisionShape2D") as CollisionShape2D
		if col == null:
			continue
		var shape := col.shape as RectangleShape2D
		if shape == null:
			continue
		var rect := Rect2(col.global_position - shape.size / 2.0, shape.size)
		if rect.has_point(world_pos):
			return true
	return false

func _get_world_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

func _input(event: InputEvent) -> void:
	if dragging and event.is_action_pressed("cancel_drag"):
		_cancel_dragging()
	elif dragging and event.is_action_released("select"):
		_drop()

func _on_target_input_event(_viewport: Node, event: InputEvent) -> void :
	if not enabled :
		return
	
	var dragging_object := get_tree().get_first_node_in_group("dragging")
	
	if not dragging and dragging_object :
		return
	
	if not dragging and event.is_action_pressed("select"):
		_start_dragging()

func _on_target_gui_event(event: InputEvent) -> void :
	_on_target_input_event(get_viewport(), event)

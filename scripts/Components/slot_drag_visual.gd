extends Node
class_name SlotDragVisual

@export var enabled: bool = true
@export var slot: Slot
@export var mouse_offset : Vector2 = Vector2(8.0,8.0)

var _drag_ghost: Control = null
var _is_dragging: bool = false

func _ready() -> void:
	assert(slot, "SlotDragVisual needs a slot target!")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _is_mouse_over_slot():
			if enabled and not _is_dragging:
				_start_drag()
		elif not event.pressed and _is_dragging:
			_end_drag()
	
	if _is_dragging and event.is_action_pressed("cancel_drag"):
		_cancel_drag()

func _process(_delta: float) -> void:
	if is_instance_valid(_drag_ghost):
		_drag_ghost.global_position = get_viewport().get_mouse_position() + mouse_offset

func _is_mouse_over_slot() -> bool:
	return slot.get_global_rect().has_point(get_viewport().get_mouse_position())

func _start_drag() -> void:
	_is_dragging = true
	_spawn_ghost()
	Events.slot_drag_started.emit(slot)

func _end_drag() -> void:
	_is_dragging = false
	_destroy_ghost()
	var world_pos := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
	Events.slot_drag_ended.emit(slot, world_pos)

func _cancel_drag() -> void:
	_is_dragging = false
	_destroy_ghost()
	Events.slot_drag_canceled.emit(slot)

func _spawn_ghost() -> void:
	_drag_ghost = Control.new()
	_drag_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_ghost.z_index = 9
	
	#var ghost_border := TextureRect.new()
	#ghost_border.texture = slot.item_border.texture
	#ghost_border.size = slot.item_border.size
	#ghost_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#_drag_ghost.add_child(ghost_border)
	
	var ghost_icon := TextureRect.new()
	ghost_icon.texture = slot.icon_sprite.texture
	ghost_icon.size = slot.icon_sprite.texture.size
	ghost_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_ghost.add_child(ghost_icon)
	
	_drag_ghost.size = slot.size
	get_tree().root.add_child(_drag_ghost)

func _destroy_ghost() -> void:
	if is_instance_valid(_drag_ghost):
		_drag_ghost.queue_free()
	_drag_ghost = null

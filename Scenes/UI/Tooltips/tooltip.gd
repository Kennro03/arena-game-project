extends Control
class_name Tooltip

const MOUSE_OFFSET : Vector2 = Vector2(8, 8) 

@onready var text_label: RichTextLabel = %TextLabel
@onready var tooltip_container: Control = %MarginContainer

@export var freeze_tooltip_delay : float = 1.0

var is_frozen : bool = false
var hovered : bool = true

func _ready() -> void:
	#await get_tree().create_timer(freeze_tooltip_delay).timeout
	#is_frozen = true
	pass

func _process(_delta: float) -> void:
	if not is_frozen :
		global_position = get_viewport().get_mouse_position() + MOUSE_OFFSET
		adjust_position()

func adjust_position() -> void:
	var vp : Rect2 = get_viewport_rect()
	var rect : Rect2 = tooltip_container.get_global_rect()
	
	if rect.end.y > vp.end.y :
		tooltip_container.global_position.y -= tooltip_container.size.y + MOUSE_OFFSET.y
	if rect.end.x > vp.end.x :
		tooltip_container.global_position.x -= tooltip_container.size.x + MOUSE_OFFSET.x
	if rect.position.y < vp.position.y :
		tooltip_container.global_position.y += tooltip_container.size.y + MOUSE_OFFSET.y
	if rect.position.x < vp.position.x :
		tooltip_container.global_position.x += tooltip_container.size.x + MOUSE_OFFSET.x

func set_text(t: String = "") -> void:
	text_label.text = t

func add_line(t: String = "") -> void:
	text_label.text += "\n"+t

func clear_text() -> void:
	text_label.text = ""

func _on_margin_container_mouse_entered() -> void:
	hovered = true

func _on_margin_container_mouse_exited() -> void:
	hovered = false

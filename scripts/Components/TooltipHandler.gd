extends Node
class_name TooltipHandler

@export var ui_root: CanvasLayer
var current_tooltip: Tooltip = null

func _ready() -> void:
	Events.tooltip_requested.connect(_on_tooltip_requested)
	Events.tooltip_cleared.connect(_on_tooltip_cleared)

func _on_tooltip_requested(tip: Tooltip)-> void :
	#print("tip script: ", tip.get_script())
	#print("is Tooltip: ", tip is Tooltip)
	#print("tip: ", tip)
	_clear()
	current_tooltip = tip
	ui_root.add_child(tip)

func _on_tooltip_cleared()-> void :
	_clear()

func _clear() -> void:
	if is_instance_valid(current_tooltip):
		current_tooltip.queue_free()
	current_tooltip = null

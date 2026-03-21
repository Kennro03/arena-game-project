extends Node
class_name OutlineHighlighter

@export var target : CanvasGroup 
@export var outline_color: Color
@export var default_outline_color: Color
@export_range(1,10) var outline_thickness: int

func _ready() -> void:
	target.material = target.material.duplicate()  
	target.material.set_shader_parameter("line_thickness",outline_thickness)

func clear_highlight()->void :
	target.material.set_shader_parameter("line_colour",default_outline_color)

func highlight()->void :
	target.material.set_shader_parameter("line_colour",outline_color)

extends Control

@export var mouse_offset : Vector2 = Vector2(12, 12) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_viewport().get_mouse_position() + mouse_offset
	adjust_position()

func adjust_position() -> void:
	var vp : Rect2 = get_viewport_rect()
	var rect : Rect2 = %PanelContainer.get_global_rect()
	
	#print("Rect pos:", rect.position, " size:", rect.size, " end:", rect.end)
	#print("VP pos:", vp.position, " size:", vp.size, " end:", vp.end)
	
	if rect.end.y > vp.end.y :
		%PanelContainer.global_position.y -= %PanelContainer.size.y + mouse_offset.y
	if rect.end.x > vp.end.x :
		%PanelContainer.global_position.x -= %PanelContainer.size.x + mouse_offset.x

func set_text(t: String = "") -> void:
	%TextLabel.text = t

func add_line(t: String = "") -> void:
	%TextLabel.text += "\n"+t

func clear_text() -> void:
	%TextLabel.text = ""

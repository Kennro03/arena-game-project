extends Control

var popup_height : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_viewport().get_mouse_position() + Vector2(12, 12) 
	adjust_position()

func adjust_position() -> void:
	var vp : Rect2 = get_viewport_rect()
	var rect : Rect2 = %PanelContainer.get_global_rect()
	
	popup_height = %PanelContainer.size.y
	
	print("Rect pos:", rect.position, " size:", rect.size, " end:", rect.end)
	print("VP pos:", vp.position, " size:", vp.size, " end:", vp.end)
	
	if not vp.encloses(rect) :
		%PanelContainer.global_position.y = global_position.y - popup_height

func set_text(t: String = "") -> void:
	%TextLabel.text = t

func add_line(t: String = "") -> void:
	%TextLabel.text += "\n"+t

func clear_text() -> void:
	%TextLabel.text = ""

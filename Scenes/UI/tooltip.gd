extends Control

var popup_height : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_viewport().get_mouse_position() + Vector2(12, 12)
	adjust_position()
	pass

func set_text(t: String = "") -> void:
	%TextLabel.text = t

func add_line(t: String = "") -> void:
	%TextLabel.text += "\n"+t

func clear_text() -> void:
	%TextLabel.text = ""


func adjust_position() -> void:
	var rect := self.get_global_rect()
	var vp := self.get_viewport_rect()
	
	popup_height = %PanelContainer.size.y
	if not vp.encloses(rect) :
		%PanelContainer.position.y = -popup_height
	else :
		%PanelContainer.position.y = 0.0

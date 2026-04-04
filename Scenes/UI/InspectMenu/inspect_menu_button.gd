extends Button
class_name InspectMenuButton

var on_pressed_action: Callable = Callable()

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if on_pressed_action.is_valid():
		on_pressed_action.call()

func setup(button_label: String, action: Callable) -> InspectMenuButton:
	text = button_label
	on_pressed_action = action
	return self

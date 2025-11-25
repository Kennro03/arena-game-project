extends HBoxContainer

var selectedColor : Color

func _on_color_picker_button_pressed() -> void:
	$PopupPanel.show()
	pass # Replace with function body.


func _on_confirm_color_button_pressed() -> void:
	$PopupPanel.hide()
	selectedColor = $PopupPanel/VBoxContainer/ColorPicker.color
	$ColorRect.color = selectedColor
	pass # Replace with function body.

extends Node
class_name SelectionManager

signal unit_selected(unit: Unit)
signal unit_deselected

var selected_unit: Unit = null

func register_unit(unit: Unit) -> void:
	unit.unit_clicked.connect(_on_unit_clicked)

func _on_unit_clicked(unit: Unit) -> void:
	if selected_unit == unit:
		# clicking same unit deselects
		deselect()
		return
	selected_unit = unit
	unit_selected.emit(unit)
	print("Unit clicked, selected unit = " + str(selected_unit))

func deselect() -> void:
	print("Deselected %s" % [selected_unit.display_name])
	selected_unit = null
	unit_deselected.emit()

func _unhandled_input(event: InputEvent) -> void:
	# click on empty space deselects
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			return
			#deselect()

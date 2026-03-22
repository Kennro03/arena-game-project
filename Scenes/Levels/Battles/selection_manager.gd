extends Node
class_name SelectionManager

var selected_unit: BaseUnit = null
@onready var unit_info_panel: UnitInfoPanel = %UnitInfoPanel

func register_unit(unit: BaseUnit) -> void:
	unit.unit_clicked.connect(_on_unit_clicked)

func _on_unit_clicked(unit: BaseUnit) -> void:
	if selected_unit == unit:
		# clicking same unit deselects
		deselect()
		return
	selected_unit = unit
	unit_info_panel.set_unit(unit)
	unit_info_panel.visible = true

func deselect() -> void:
	selected_unit = null
	unit_info_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# click on empty space deselects
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			deselect()

extends Node
class_name SelectionManager

var selected_unit: BaseUnit = null
@onready var unit_info_panel_scene: PackedScene = load("res://Scenes/UI/UnitInfoPanel/unit_info_panel.tscn")

func _process(delta: float) -> void:
	if Input.is_action_pressed("DisplayUnitInfo") :
		spawn_unit_info_panel()

func register_unit(unit: BaseUnit) -> void:
	unit.unit_clicked.connect(_on_unit_clicked)

func _on_unit_clicked(unit: BaseUnit) -> void:
	if selected_unit == unit:
		# clicking same unit deselects
		deselect()
		return
	selected_unit = unit
	print("Unit clicked, selected unit = " + str(selected_unit))

func deselect() -> void:
	selected_unit = null

func _unhandled_input(event: InputEvent) -> void:
	# click on empty space deselects
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			return
			#deselect()

func spawn_unit_info_panel()->void:
	if not selected_unit :
		return
	var panel_name := selected_unit.id + "_InfoPanel"
	if %UI.get_node_or_null(panel_name) != null :
		return
	var panel := unit_info_panel_scene.instantiate()
	panel.unit = selected_unit
	panel.name = panel_name
	%UI.add_child(panel) 

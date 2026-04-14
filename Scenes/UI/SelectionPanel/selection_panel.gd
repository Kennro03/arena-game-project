extends Control
class_name SelectionPanel

signal selection_confirmed(selected: Array)
signal selection_changed(selected: Array)

enum SelectionType { UNIT, ITEM, WEAPON, ARMOR, ACCESSORY }

@export var max_selections: int = 1
@export var min_selections: int = 1 
@export var selection_type: SelectionType
@export var confirm_button_label: String = "Confirm"

@onready var selection_title: Label = %SelectionTitle
@onready var selection_container: GridContainer = %SelectionContainer
@onready var confirm_button: Button = %ConfirmButton
@onready var selection_counter_label: Label = %SelectionCounterLabel

const UNIT_SLOT_SCENE := preload("res://Scenes/UI/reserve/unit_slot.tscn")
const ITEM_SLOT_SCENE := preload("res://Scenes/UI/inventory/item_slot.tscn")

var selected: Array = []
var _slots: Array = []

func _ready() -> void:
	confirm_button.text = confirm_button_label
	confirm_button.disabled = true
	confirm_button.pressed.connect(_on_confirm)
	_populate()

func setup(type: SelectionType, max_sel: int, min_sel: int = 1) -> SelectionPanel:
	selection_type = type
	max_selections = max_sel
	min_selections = min_sel
	return self

func _populate() -> void:
	for child in selection_container.get_children():
		child.queue_free()
	_slots.clear()
	selected.clear()
	
	var items := _get_items_for_type()
	for item in items:
		var slot := _create_slot(item)
		_slots.append(slot)
	
	_update_ui()

func _get_items_for_type() -> Array:
	match selection_type:
		SelectionType.UNIT:
			return Player.reserve + Player.team
		SelectionType.ITEM:
			return Player.inventory
		SelectionType.WEAPON:
			return Player.inventory.filter(func(i): return i is Weapon)
		SelectionType.ARMOR:
			return Player.inventory.filter(func(i): return i is Armor)
		SelectionType.ACCESSORY:
			return Player.inventory.filter(func(i): return i is Accessory)
	return []

func _create_slot(data) -> Control:
	var slot: Control
	if selection_type == SelectionType.UNIT:
		slot = UNIT_SLOT_SCENE.instantiate()
		selection_container.add_child(slot)
		slot.set_unit(data)
	else:
		slot = ITEM_SLOT_SCENE.instantiate()
		selection_container.add_child(slot)
		slot.set_item(data)
		slot.drag_visual.enabled = false
	
	slot.slot_clicked.connect(func(s, button):
		if button == MOUSE_BUTTON_LEFT:
			_toggle_selection(s, data))
	
	return slot

func _toggle_selection(slot: Control, data) -> void:
	if data in selected:
		selected.erase(data)
		slot.modulate = Color.WHITE
	else:
		if selected.size() >= max_selections:
			# deselect oldest if at max
			var oldest : Object = selected[0]
			selected.erase(oldest)
			var oldest_slot : Slot = _slots[_get_items_for_type().find(oldest)]
			if is_instance_valid(oldest_slot):
				oldest_slot.modulate = Color.WHITE
		selected.append(data)
		slot.modulate = Color(0.5, 1, 0.30, 1.0)  # color selected
	
	_update_ui()
	selection_changed.emit(selected)

func _update_ui() -> void:
	confirm_button.disabled = selected.size() < min_selections
	selection_counter_label.text = "%d / %d selected" % [selected.size(), max_selections]

func _on_confirm() -> void:
	selection_confirmed.emit(selected.duplicate())
	
	queue_free()

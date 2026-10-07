extends VBoxContainer
class_name CollapsibleChecklist

signal selection_changed(selected_items: Array)

@export var title: String = "Checklist":
	set(v):
		title = v
		if is_node_ready():
			_header_button.text = "%s (%d selected)" % [title, get_selected().size()]

@export var items: Array[String] = []
@export var default_all_selected: bool = false
@export var collapsed: bool = true:
	set(v):
		collapsed = v
		if is_node_ready():
			_content.visible = not collapsed
			_header_button.text = "▶ %s (%d selected)" % [title, get_selected().size()] if collapsed else "▼ %s (%d selected)" % [title, get_selected().size()]

var _header_button: Button
var _content: ScrollContainer
var _checkboxes: VBoxContainer
var _check_nodes: Array[CheckBox] = []

func _ready() -> void:
	# header row
	var header := HBoxContainer.new()
	
	_header_button = Button.new()
	_header_button.flat = true
	_header_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_header_button.pressed.connect(func(): collapsed = not collapsed)
	header.add_child(_header_button)
	
	# select all / none buttons
	var all_btn := Button.new()
	all_btn.text = "All"
	all_btn.custom_minimum_size.x = 36
	all_btn.pressed.connect(func(): _set_all(true))
	header.add_child(all_btn)
	
	var none_btn := Button.new()
	none_btn.text = "None"
	none_btn.custom_minimum_size.x = 40
	none_btn.pressed.connect(func(): _set_all(false))
	header.add_child(none_btn)
	
	add_child(header)
	
	# scrollable content
	_content = ScrollContainer.new()
	_content.custom_minimum_size.y = 120
	_content.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_content.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_checkboxes = VBoxContainer.new()
	_content.add_child(_checkboxes)
	add_child(_content)
	
	populate(items)
	collapsed = collapsed

func populate(new_items: Array[String]) -> void:
	items = new_items
	for c in _checkboxes.get_children():
		c.queue_free()
	_check_nodes.clear()
	for item in items:
		var cb := CheckBox.new()
		cb.text = item
		cb.button_pressed = default_all_selected
		cb.toggled.connect(func(_v): _on_selection_changed())
		_checkboxes.add_child(cb)
		_check_nodes.append(cb)
	_on_selection_changed()

func get_selected() -> Array[String]:
	var result: Array[String] = []
	for cb in _check_nodes:
		if cb.button_pressed:
			result.append(cb.text)
	return result

func _set_all(value: bool) -> void:
	for cb in _check_nodes:
		cb.button_pressed = value
	_on_selection_changed()

func _on_selection_changed() -> void:
	var selected := get_selected()
	_header_button.text = "▶ %s (%d/%d)" % [title, selected.size(), items.size()] if collapsed else "▼ %s (%d/%d)" % [title, selected.size(), items.size()]
	selection_changed.emit(selected)

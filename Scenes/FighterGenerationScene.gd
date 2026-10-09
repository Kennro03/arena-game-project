extends Control
class_name FighterGenerationScene

signal generation_complete(fighters: Array[FighterData], config: Resource)

const PARTICIPANT_SLOT = preload("res://Scenes/participant_slot.tscn")

enum Mode { ARENA, TOURNAMENT }

# set by the calling setup scene before adding to tree
var mode: Mode = Mode.ARENA
var arena_config: ArenaConfig = null
var tournament_config: Resource = null  # change this to TournamentConfig

@export var min_fighters: int = 20
@export var max_fighters: int = 0          # 0 = unlimited
@export var base_unit_data: UnitData = UnitData.new()

@onready var mode_label: RichTextLabel = %ModeLabel
@onready var fighter_count_label: RichTextLabel = %FighterCountLabel
@onready var slots_container: GridContainer = %SlotsContainer
@onready var proceed_button: Button = %ProceedButton
@onready var add_slot_button: Button = %AddSlotButton
@onready var remove_slot_button: Button = %RemoveSlot
@onready var generation_tool: GenerationToolPanel = %GenerationToolPanel
@onready var custom_fighter_panel: CustomFighterPanel = %CustomFighterPanel

var _slots: Array[ParticipantSlot] = []

func _ready() -> void:
	_setup_mode_ui()
	proceed_button.pressed.connect(_on_proceed)
	add_slot_button.pressed.connect(_add_empty_slot)
	remove_slot_button.pressed.connect(_remove_last_slot)
	generation_tool.generate_requested.connect(_on_batch_generate)
	custom_fighter_panel.fighter_created.connect(_on_custom_fighter_created)
	
	generation_tool.exp_spinbox.value = _get_starting_exp()
	
	for i in min_fighters:
		_add_empty_slot()
	_refresh_ui()

func _get_starting_exp() -> int:
	match mode:
		Mode.ARENA:
			return 0
		Mode.TOURNAMENT:
			return 0  # tournament_config.starting_exp when implemented
	return 0

func _setup_mode_ui() -> void:
	match mode:
		Mode.ARENA:
			mode_label.text = "Arena — Fighter Setup"
			proceed_button.text = "Start Arena →"
		Mode.TOURNAMENT:
			mode_label.text = "Tournament — Fighter Setup"
			proceed_button.text = "Generate Bracket →"
			# tournaments need power-of-2 fighter counts
			# disable free add/remove, enforce valid counts
			_enforce_tournament_count()

func _enforce_tournament_count() -> void:
	# snap min_fighters to nearest power of 2
	var valid := 2
	while valid < min_fighters:
		valid *= 2
	min_fighters = valid
	# show only valid counts in a dropdown instead of free spinbox
	add_slot_button.visible = false
	remove_slot_button.visible = false

func _add_empty_slot() -> void:
	if max_fighters > 0 and _slots.size() >= max_fighters:
		return
	var slot := PARTICIPANT_SLOT.instantiate() as ParticipantSlot
	slots_container.add_child(slot)
	_slots.append(slot)
	#slot.fighter_changed.connect(_refresh_ui)
	slot.remove_requested.connect(func(): _erase_slot_fighter(slot))
	slot.export_requested.connect(func(): _export_slot(slot))
	_refresh_ui()

func _remove_slot(slot: ParticipantSlot) -> void:
	if _slots.size() <= min_fighters:
		return  # can't go below minimum
	_slots.erase(slot)
	slot.queue_free()
	_refresh_ui()
	
func _erase_slot_fighter(slot: ParticipantSlot) -> void:
	slot.set_fighter(null)
	_refresh_ui()

func _remove_last_slot() -> void:
	if _slots.size() <= min_fighters:
		return  # can't go below minimum
	_slots.erase(_slots.back())
	var slots : Array[Node] = slots_container.get_children() 
	slots.back().queue_free()
	_refresh_ui()

func _export_slot(_slot: ParticipantSlot) -> void :
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.filters = ["*.tres ; Fighters Data"]
	dialog.current_path = "res://Fighters/"
	dialog.current_file = _slot._fighter_data.unit_data.display_name
	dialog.file_selected.connect(func(path):
		ResourceSaver.save(_slot._fighter_data,path)
		dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered()

func on_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE) # Write to the file
	file.store_string("Hello from Godot!")
	file.close()

func _refresh_ui() -> void:
	var filled := _slots.filter(func(s): return s._fighter_data!= null).size()
	fighter_count_label.text = "%d / %d fighters ready" % [filled, _slots.size()]
	proceed_button.disabled = filled < min_fighters
	add_slot_button.disabled = max_fighters > 0 and _slots.size() >= max_fighters

func _on_batch_generate(count: int, config: FighterGenerationConfig) -> void:
	# fill empty slots first, then add new ones if needed
	var empty_slots := _slots.filter(func(s): return not s.has_fighter())
	var target_count := mini(count, empty_slots.size())
	
	for i in target_count:
		var fighter := _generate_one(config)
		empty_slots[i].set_fighter(fighter)
	
	# if more needed and slots available, add new slots
	var remaining := count - target_count
	for i in remaining:
		if max_fighters > 0 and _slots.size() >= max_fighters:
			break
		_add_empty_slot()
		var fighter := _generate_one(config)
		_slots.back().set_fighter(fighter)
	
	_refresh_ui()

func _generate_one(config: FighterGenerationConfig) -> FighterData:
	var archetype: StatArchetype = null
	if not config.allowed_stat_archetypes.is_empty():
		archetype = config.allowed_stat_archetypes.pick_random()
	var tags: Array[String] = []
	if not config.allowed_tags.is_empty():
		var shuffled := config.allowed_tags.duplicate()
		shuffled.shuffle()
		tags = shuffled.slice(0, randi_range(0, 2))
	return FighterGenerator.generate(archetype, tags, config.starting_exp, humanoidUnitData.new())

func _on_custom_fighter_created(fighter: FighterData) -> void:
	# fill first empty slot or add a new one
	for slot in _slots:
		if not slot.has_fighter():
			slot.set_fighter(fighter)
			_refresh_ui()
			return
	_add_empty_slot()
	_slots.back().set_fighter(fighter)
	_refresh_ui()

func _on_proceed() -> void:
	var fighters: Array[FighterData] = []
	for slot in _slots:
		if slot.has_fighter():
			fighters.append(slot.get_fighter())
	
	match mode:
		Mode.ARENA:
			generation_complete.emit(fighters, arena_config)
		Mode.TOURNAMENT:
			# validate count is power of 2 for tournament
			if not _is_power_of_two(fighters.size()):
				_show_invalid_count_warning()
				return
			generation_complete.emit(fighters, tournament_config)
	queue_free()

func _is_power_of_two(n: int) -> bool:
	return n > 0 and (n & (n - 1)) == 0

func _show_invalid_count_warning() -> void:
	var valid := [2, 4, 8, 16, 32, 64]
	var nearest : Array = valid.filter(func(v): return v >= _slots.filter(
		func(s): return s.has_fighter()).size()).front()
	push_warning("Tournament needs power-of-2 fighters. Nearest valid count: %d" % nearest)
	#could use popup here

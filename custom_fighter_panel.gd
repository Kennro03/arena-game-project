extends PanelContainer
class_name CustomFighterPanel

signal fighter_created(fighter: FighterData)

@onready var name_input: LineEdit = %NameInput
@onready var lvl_spinbox: SpinBox = %LvlSpinBox
@onready var exp_spinbox: SpinBox = %ExpSpinBox
@onready var archetype_option: OptionButton = %ArchetypeOption

@onready var tag_selection_vbox: VBoxContainer = %TagSelectionVbox

@onready var import_button: Button = %ImportButton
@onready var create_button: Button = %CreateButton

var _tag_list: CollapsibleChecklist

func _ready() -> void:
	for archetype in ["Wildcard", "Physical", "Ethereal",
	# For random stats archetypes :
		# TRRS = Totally random remaining stats
		# BRS = Balanced remaining stats (will need a way to balance out spending stats)
		# M = main stat, S = secondary stat, T = tertiary stat, R = remaining stats
		 "TRRS 100M", #focused on one stat only
		 "TRRS 80M-20S", "TRRS 70M-30S", "TRRS 60M-40S", "TRRS 50M-50S", #focused on two stats only
		 "TRRS 60M-20S-20T", "TRRS 40M-20S-20T-20R", "TRRS 20M-20S-20T-40R", #focused on three stats only
		 "TRRS 80M-20R", "TRRS 70M-30R", "TRRS 60M-40R", "TRRS 50M-50R", #focused on one stat and spreads the rest
		 "TRRS 60M-20S-20R", "TRRS 40M-40S-20R", "TRRS 20M-20S-60R", #focused on two stats and spreads the rest
		 "TRRS 34M-33S-33T", #focused around three stats only
	]:
		archetype_option.add_item(archetype)
	
	_tag_list = CollapsibleChecklist.new()
	_tag_list.title = "Focused tags"
	tag_selection_vbox.add_child(_tag_list)
	_tag_list.populate(
		["melee", "ranged", "physical","ethereal",
		 "slash", "pierce", "blunt",
		 "sword", "bow", "spear", "dagger", "hammer", "gauntlet", "magi_focus",
		 "fire", "frost", "lightning", "wind", "water", "earth", "order", "entropy",
		])
	
	create_button.pressed.connect(_on_create)
	import_button.pressed.connect(_on_import)

func _on_create() -> void:
	var tags: Array[String] = _tag_list.get_selected()
	var archetype := _build_archetype_from_selection()
	
	# use level to compute starting exp if level spinbox is set
	var starting_exp := int(exp_spinbox.value)
	if lvl_spinbox.value > 1:
		starting_exp = Stats.get_xp_for_level(int(lvl_spinbox.value))
	
	var base := UnitData.new()
	var fighter := FighterGenerator.generate(archetype, tags, starting_exp, base)
	
	if not name_input.text.is_empty():
		fighter.unit_data.display_name = name_input.text
	
	fighter_created.emit(fighter)

func _build_archetype_from_selection() -> StatArchetype:
	var name := archetype_option.get_item_text(archetype_option.selected)
	if name == "Wildcard":
		return null
	return GenerationToolPanel._name_to_archetype(name)

func _on_import() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.filters = ["*.tres ; Unit Data"]
	dialog.current_path = "res://Fighters/"
	dialog.file_selected.connect(func(path):
		var data := load(path) as FighterData
		if data:
			fighter_created.emit(data)
		dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered()

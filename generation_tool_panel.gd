extends PanelContainer
class_name GenerationToolPanel

signal config_changed(config: FighterGenerationConfig)
signal generate_requested(count: int, config: FighterGenerationConfig)

var weapons_bases_list : Dictionary = {
	"bow" : preload("uid://cikjn1d3hom5x"), 
	"gauntlets" : preload("uid://evw15hgtlv7a"),
	"dagger" : preload("uid://dal5rgfowl103"), 
	"broadsword" : preload("uid://cpnr5mpvtakmp"),
	"spear" : preload("uid://cje1th2326lj"), 
	"foci staff" : preload("uid://ds6y5tv4n4hsx"), 
	"warhammer" : preload("uid://cseh3bpxs7l8k"), 
	"greatsword" : preload("uid://bwlni7c3utacx"), 
}

@onready var exp_spinbox: SpinBox = %ExpSpinbox
@onready var level_spinbox: SpinBox = %LvlSpinbox
@onready var count_spinbox: SpinBox = %CountSpinbox
@onready var wildcard_check: CheckBox = %WildcardCheck
@onready var generate_button: Button = %GenerateButton
@onready var checklists_container: VBoxContainer = %ChecklistsContainer

var _archetype_list: CollapsibleChecklist
var _tag_list: CollapsibleChecklist
var _weapon_base_list: CollapsibleChecklist
var _weapon_material_list: CollapsibleChecklist
var _accessory_list: CollapsibleChecklist

func _ready() -> void:
	_build_checklists()
	generate_button.pressed.connect(_on_generate)

func _build_checklists() -> void:
	_archetype_list = _make_checklist(
		"Stat Archetypes",
		["Physical", "Ethereal", 
		# For random stats archetypes :
		# TRRS = Totally random remaining stats
		# BRS = Balanced remaining stats (will need a way to balance out spending stats)
		# M = main stat, S = secondary stat, T = tertiary stat, R = remaining stats
		 "TRRS 100M", #focused on one stat only
		 "TRRS 80M-20S", "TRRS 70M-30S", "TRRS 60M-40S", "TRRS 50M-50S", #focused on two stats only
		 "TRRS 60M-20S-20T", "TRRS 40M-20S-20T-20R", "TRRS 20M-20S-20T-40R", #focused on three stats only
		 "TRRS 80M-20R", "TRRS 70M-30R", "TRRS 60M-40R", "TRRS 50M-50R", #focused on one stat and spreads the rest
		 "TRRS 60M-20S-20R", "TRRS 40M-40S-20R", "TRRS 20M-20S-60R", #focused on two stats and spreads the rest
		]) 
	
	_tag_list = _make_checklist(
		"Tag Priority Pool",
		["melee", "ranged", "physical","ethereal",
		 "slash", "pierce", "blunt",
		 "sword", "bow", "spear", "dagger", "hammer", "gauntlet", "magi_focus",
		 "fire", "frost", "lightning", "wind", "water", "earth", "order", "entropy",
		])
	
	var weapons_names_list : Array[String] = []
	for entry in weapons_bases_list.keys() : 
		weapons_names_list.append(entry)
	_weapon_base_list = _make_checklist(
		"Allowed Weapon Bases",
		weapons_names_list)  # ["bow", "gauntlets", "dagger", ...]

	var materials_list := MaterialRegistry.get_all_materials()
	materials_list.sort_custom(func(a, b): return a.tier < b.tier)
	var material_names: Array[String] = []              # .map() returns untyped Array — use a loop
	for mat in materials_list:
		material_names.append(mat.material_name)
	_weapon_material_list = _make_checklist("Weapon Materials", material_names)
	
	var _accessories : Array[Accessory] = []
	var accessory_names : Array[String] = []
	_accessory_list = _make_checklist(
		"Allowed Accessories", 
		accessory_names)  # populated from loaded resources

func _make_checklist(title: String, items: Array[String]) -> CollapsibleChecklist:
	var cl := CollapsibleChecklist.new()
	cl.title = title
	checklists_container.add_child(cl)
	cl.default_all_selected = true
	cl.populate(items)
	return cl

func build_config() -> FighterGenerationConfig:
	var config := FighterGenerationConfig.new()
	config.starting_exp = int(exp_spinbox.value)
	config.starting_level = int(level_spinbox.value)
	config.allow_wildcard = wildcard_check.button_pressed
	config.allowed_tags = _tag_list.get_selected()
	
	# map archetype names to StatArchetype instances
	config.allowed_stat_archetypes = _build_archetypes_from_selection()
	
	config.allowed_weapon_bases = []
	for weapon_name in _weapon_base_list.get_selected():
		if weapons_bases_list.has(weapon_name):
			config.allowed_weapon_bases.append(weapons_bases_list[weapon_name])

	# Materials — already correct, just kept as-is
	config.allowed_weapon_materials = []
	var all_materials := MaterialRegistry.get_all_materials()
	for mat_name in _weapon_material_list.get_selected():
		for mat in all_materials:
			if mat.material_name == mat_name:
				config.allowed_weapon_materials.append(mat)
				break
	
	return config

func _build_archetypes_from_selection() -> Array[StatArchetype]:
	var result: Array[StatArchetype] = []
	for _name in _archetype_list.get_selected():
		var archetype := _name_to_archetype(_name)
		if archetype:
			result.append(archetype)
	return result

static func _name_to_archetype(_name: String) -> StatArchetype:
	match _name:
		"Physical":  return StatArchetype.physical()
		"Ethereal":  return StatArchetype.ethereal()
		_:
			if _name.begins_with("TRRS") or _name.begins_with("BRS"):
				return StatArchetype.from_trrs(_name)
	return null

func _on_generate() -> void:
	generate_requested.emit(int(count_spinbox.value), build_config())

extends Control
class_name ArenaSetupScene



const FIGHTER_GENERATION_SCENE = preload("res://Scenes/fighter_generation_scene.tscn")

# fight rules
@onready var round_format_option: OptionButton = %RoundFormatOption
@onready var max_duration_spinbox: SpinBox = %MaxDurationSpinbox
@onready var timeout_option: OptionButton = %TimeoutOption
@onready var draw_behavior_option: OptionButton = %DrawBehaviorOption

# progression
@onready var prog_every_x_fight_spinbox: SpinBox = %ProgAfterSpinbox
@onready var exp_per_fight_spinbox: SpinBox = %ExpPerFightSpinbox
@onready var lvl_per_fight_spinbox: SpinBox = %LvlPerFightSpinbox

# gear
@onready var gear_handling_option: OptionButton = %GearHandlingOption
var _reroll_weapon_type_list: CollapsibleChecklist
var _reroll_weapon_mat_list: CollapsibleChecklist
var _reroll_accessories_list: CollapsibleChecklist
@onready var accessory_reroll_count_spinbox: SpinBox = %RerollAccessoryCountSpinbox

# simulation
@onready var spectated_check: CheckBox = %SpectatedCheck
@onready var pause_between_check: CheckBox = %PauseBetweenCheck
@onready var simulation_speed_spin_box: SpinBox = %SimulationSpeedSpinBox
@onready var simulation_speed_slider: HSlider = %SimulationSpeedSlider

@onready var min_fighters_spinbox: SpinBox = %MinFightersSpinbox
@onready var proceed_button: Button = %ProceedButton
@onready var close_button: Button = %CloseButton

# reroll_section only display if gear handling = Reroll
@onready var reroll_section: VBoxContainer = %RerollSection
@onready var reroll_weapon_type_container: HBoxContainer = %RerollWeaponTypeContainer
@onready var reroll_weapon_mat_container: HBoxContainer = %RerollWeaponMatContainer
@onready var reroll_allowed_accessories_container: HBoxContainer = %RerollAllowedAccessoriesContainer
@onready var reroll_accessory_count_spinbox: SpinBox = %RerollAccessoryCountSpinbox

func _ready() -> void:
	_populate_options()
	_build_checklists()
	proceed_button.pressed.connect(_on_proceed)
	simulation_speed_spin_box.value_changed.connect(simulation_speed_slider.set_value_no_signal)
	simulation_speed_slider.value_changed.connect(simulation_speed_spin_box.set_value_no_signal)
	spectated_check.toggled.connect(func(v):
		pause_between_check.visible = v
		simulation_speed_spin_box.visible = not v
		simulation_speed_slider.visible = not v)
	
	gear_handling_option.item_selected.connect(func(index):
		reroll_section.visible = index == ArenaConfig.GearHandling.REROLL_AFTER_FIGHT)
	reroll_section.visible = false

func _populate_options() -> void:
	for key in ArenaConfig.TimeoutBehavior.keys():
		timeout_option.add_item(key.capitalize().replace("_", " "))
	timeout_option.selected = 1
	for key in ArenaConfig.DrawBehavior.keys():
		draw_behavior_option.add_item(key.capitalize().replace("_", " "))
	draw_behavior_option.selected = 1
	for key in ArenaConfig.GearHandling.keys():
		gear_handling_option.add_item(key.capitalize().replace("_", " "))
	for key in ArenaConfig.RoundFormat.keys():
		round_format_option.add_item(key.capitalize().replace("_", " "))

func _build_checklists() -> void:
	var weapon_type_names: Array[String] = []
	for key in Weapon.WeaponTypeEnum.keys():
		if key != "UNARMED":
			weapon_type_names.append(key.capitalize())
	
	var item_materials : Array[ItemMaterial] = MaterialRegistry.get_all_materials()
	item_materials.sort_custom(func(a, b): return a.tier < b.tier)
	var material_names: Array[String] = []
	for item_material in item_materials :
		material_names.append(item_material.material_name)
	
	
	# generation gear checklists
	_reroll_weapon_type_list = _make_checklist(
		reroll_weapon_type_container, 
		"Allowed Weapon Types", 
		weapon_type_names)
	
	_reroll_weapon_mat_list = _make_checklist(
		reroll_weapon_mat_container, 
		"Allowed Materials", 
		material_names)
	
	var _accessories : Array[Accessory] = []
	var accessory_names : Array[String] = []
	_reroll_accessories_list = _make_checklist(
		reroll_allowed_accessories_container,
		"Allowed accessories",
		accessory_names,
	)

func _make_checklist(parent: Control, title: String, items: Array[String]) -> CollapsibleChecklist:
	var cl := CollapsibleChecklist.new()
	cl.title = title
	cl.default_all_selected = true
	parent.add_child(cl)
	cl.populate(items)
	return cl

func _weapon_type_names_to_enums(names: Array[String]) -> Array[Weapon.WeaponTypeEnum]:
	var result: Array[Weapon.WeaponTypeEnum] = []
	for name in names:
		var key := name.to_upper()
		var idx := Weapon.WeaponTypeEnum.keys().find(key)
		if idx >= 0:
			result.append(idx as Weapon.WeaponTypeEnum)
	return result

func _material_names_to_resources(names: Array[String]) -> Array[ItemMaterial]:
	var all := MaterialRegistry.get_all_materials()
	var result: Array[ItemMaterial] = []
	for mat in all:
		if mat.material_name in names:
			result.append(mat)
	return result

func build_config() -> ArenaConfig:
	var config := ArenaConfig.new()
	# Fight behavior
	config.max_fight_duration = max_duration_spinbox.value
	config.timeout_behavior = timeout_option.selected as ArenaConfig.TimeoutBehavior
	config.draw_behavior = draw_behavior_option.selected as ArenaConfig.DrawBehavior
	config.round_format = round_format_option.selected as ArenaConfig.RoundFormat
	
	# Progression
	config.progression_every_x_fight = int(prog_every_x_fight_spinbox.value)
	config.exp_gained_per_prog = int(exp_per_fight_spinbox.value)
	config.level_gained_per_prog = int(lvl_per_fight_spinbox.value)
	
	# Gear handling
	config.gear_handling = gear_handling_option.selected as ArenaConfig.GearHandling
	config.number_of_accessories_rerolled = int(accessory_reroll_count_spinbox.value)
	config.reroll_allowed_weapon_types = _weapon_type_names_to_enums(
		_reroll_weapon_type_list.get_selected())
	config.reroll_allowed_weapon_materials = _material_names_to_resources(
		_reroll_weapon_mat_list.get_selected())
	config.reroll_allowed_accessories = [] ## TODO
	config.number_of_accessories_rerolled = int(accessory_reroll_count_spinbox.value)
	
	#Spectating
	config.spectated = spectated_check.button_pressed
	config.pause_between_rounds = pause_between_check.button_pressed
	config.simulation_speed = simulation_speed_slider.value
	
	config._seed = randi()
	return config

func _on_proceed() -> void:
	var config := build_config()
	var gen_scene := FIGHTER_GENERATION_SCENE.instantiate() as FighterGenerationScene
	gen_scene.mode = FighterGenerationScene.Mode.ARENA
	gen_scene.arena_config = config
	gen_scene.min_fighters = int(min_fighters_spinbox.value)
	gen_scene.generation_complete.connect(_on_fighters_ready)
	if Player.ui_layer :
		Player.ui_layer.add_child(gen_scene)
	else :
		get_tree().root.add_child(gen_scene)
	hide()

func _on_fighters_ready(fighters: Array[FighterData], config: Resource) -> void:
	var arena_config := config as ArenaConfig
	if arena_config == null:
		printerr("ArenaSetupScene: invalid config")
		return
	# store for ArenaCircuit to consume
	Player.pending_arena_fighters = fighters
	Player.pending_arena_config = arena_config
	# transition via SceneLoader
	SceneLoader.load_scene("res://Scenes/arena_circuit.tscn")
	queue_free()

func _on_close_button_pressed() -> void:
	queue_free()

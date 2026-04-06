extends Control
class_name UnitInfoPanel

var unit_scene := preload("res://Scenes/Units/Stickman/stickman.tscn")
var placeholderTarget : BaseUnit = unit_scene.instantiate()
@export var unit : BaseUnit = null

@onready var iconRect := %UnitIcon
@onready var nameLabel := %UnitNameLabel
@onready var typeLabel := %UnitTypeLabel
@onready var descriptionLabel := %UnitDescriptionLabel

@onready var levelLabel := %UnitLevelLabel
@onready var levelProgressBar := %LevelProgressBar

@onready var health_bar: ProgressBar = %HealthBar

@onready var gear_slots: HBoxContainer = %GearSlots
@onready var accessories_slots: HBoxContainer = %AccessoriesSlots

@onready var attributesList := %AttributesContainer
@onready var statsList := %StatsContainer
@onready var statusesList := %StatusEffectsContainer

const attribute_row_scene : PackedScene = preload("uid://dpwd2brx4n2vh")
const status_effect_row : PackedScene = preload("uid://dofk34fycohsp")
const item_slot_scene : PackedScene = preload("uid://dnm02uo4msg2e")
const weapon_slot_scene : PackedScene = preload("uid://cr0ku2232m77j")
const armor_slot_scene : PackedScene = preload("uid://bpkurgfb4csud")
const accessory_slot_scene : PackedScene = preload("uid://dd2psrpeofhbi")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if unit == null :
		printerr("No unit provided to UnitInfoPanel ! Give it one before spawning.")
		return
	set_unit.call_deferred(unit)
	
	#placeholderTarget.stats = Stats.new()
	#placeholderTarget.stats.experience = 220
	#placeholderTarget.position = Vector2(500.0,100.0)
	#get_tree().root.add_child.call_deferred(placeholderTarget)
	
	#set_unit.call_deferred(placeholderTarget)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_unit(target: BaseUnit) -> void:
	unit = target
	
	unit.stats.stats_recalculated.connect(_on_stats_changed)
	unit.stats.exp_changed.connect(_on_experience_changed)
	unit.stats.health_changed.connect(_on_health_changed)
	unit.statusEffectModule.effects_changed.connect(set_status_effects)
	
	set_info()
	set_experience()
	set_health()
	set_gear()
	set_stats()
	set_status_effects()

func set_info() ->void :
	iconRect.texture = unit.icon if unit.icon else null
	nameLabel.text = unit.display_name
	typeLabel.text = "Unit type : " + unit.get_class()
	
	descriptionLabel.text = unit.description

func set_experience() -> void:
	levelLabel.text = "Unit Level : " + str(unit.stats.level)
	levelProgressBar.min_value = 0.0
	levelProgressBar.max_value = 1.0
	levelProgressBar.value = unit.stats.get_level_progress()
	# optional tooltip
	levelProgressBar.tooltip_text = "%d / %d XP" % [
		unit.stats.get_xp_in_current_level(),
		unit.stats.get_xp_needed_for_next_level()
	]

func set_health() -> void:
	health_bar.max_value = unit.stats.current_max_health
	health_bar.value = unit.stats.health

func _on_stats_changed() -> void :
	set_info()   # for name and info
	set_stats()  # for stats

func _on_experience_changed() -> void :
	set_experience()
	pass

func clear_gear() -> void :
	for c in gear_slots.get_children() :
		c.queue_free()
	
	for c in accessories_slots.get_children() :
		c.queue_free()

func set_gear() -> void :
	clear_gear()
	var weapon_slot : WeaponSlot = weapon_slot_scene.instantiate()
	weapon_slot.item = unit.weapon
	gear_slots.add_child(weapon_slot)
	var armor_slot : ArmorSlot = armor_slot_scene.instantiate()
	armor_slot.item = unit.armor
	gear_slots.add_child(armor_slot)
	
	var i : int = 0
	while i < unit.accessory_limit :
		var accessory_slot : AccessorySlot = accessory_slot_scene.instantiate()
		accessory_slot.item = unit.accessories[i]
		gear_slots.add_child(accessory_slot)
		i += 1

func set_stats() ->void :
	for child in attributesList.get_children():
		child.queue_free()
	for child in statsList.get_children():
		child.queue_free()
	for attribute in unit.stats.Attributes.values() :
		var row := attribute_row_scene.instantiate()
		row.iconTexture = Stats.attribute_icons[attribute]
		row.attributeName = Stats.Attributes.keys()[attribute] + " : "
		row.attributeValue = str(unit.stats.get_current_attribute(attribute)) if unit.stats else "..."
		attributesList.add_child(row)
	for stat in unit.stats.BuffableStats :
		if !unit.stats.Attributes.has(stat) :
			var row := attribute_row_scene.instantiate()
			row.attributeName = str(stat) + " : "
			row.attributeValue = str(unit.stats.get_current_stat(unit.stats.BuffableStats[stat])) if unit.stats else "..."
			statsList.add_child(row)

func set_status_effects() ->void :
	#for child in statusesList.get_children():
	#	child.queue_free()
	if unit.statusEffectModule :
		for status in unit.statusEffectModule.StatusEffects :
			var row := status_effect_row.instantiate()
			row.status_effect = status
			statusesList.add_child(row)

func _on_health_changed(health : float,max_health : float) -> void :
	health_bar.max_value = max_health
	health_bar.value = health

func _on_close_button_pressed() -> void:
	queue_free()

extends Control
class_name UnitInfoPanel

var unit_scene := preload("res://Scenes/Units/Stickman/stickman.tscn")
var placeholderTarget : BaseUnit = unit_scene.instantiate()

var unit 

@onready var iconRect := %UnitIcon
@onready var nameLabel := %UnitNameLabel
@onready var typeLabel := %UnitTypeLabel
@onready var levelLabel := %UnitLevelLabel
@onready var unit_health_label: Label = %UnitHealthLabel
@onready var unit_shield_label: Label = %UnitShieldLabel
@onready var descriptionLabel := %UnitDescriptionLabel
@onready var stat_details_label: RichTextLabel = %StatDetailsLabel

@onready var gear_vbox_container: VBoxContainer = %GearVboxContainer
const GEAR_CONTAINER = preload("uid://cjeix22vpufqd")


#@onready var attributesList := %AttributesContainer
#@onready var statsList := %StatsContainer
#@onready var statusesList := %StatusEffectsContainer

const attribute_row_scene : PackedScene = preload("uid://dpwd2brx4n2vh")
const status_effect_row : PackedScene = preload("uid://dofk34fycohsp")
const item_slot_scene : PackedScene = preload("uid://dnm02uo4msg2e")
const weapon_slot_scene : PackedScene = preload("uid://cr0ku2232m77j")
const armor_slot_scene : PackedScene = preload("uid://bpkurgfb4csud")
const accessory_slot_scene : PackedScene = preload("uid://dd2psrpeofhbi")

const STAT_ENTRY_ROW : PackedScene = preload("uid://c4gvcfxbmslqu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit = preload("res://ressources/Units/unit_data/Pablo.tres")
	
	if unit == null :
		printerr("No unit provided to UnitInfoPanel ! Give it one before spawning.")
		return
	
	if unit is UnitData and is_instance_valid(unit):
		_setup_data.call_deferred(unit)
	elif unit is BaseUnit and is_instance_valid(unit):
		_setup_live.call_deferred(unit)
	else :
		printerr("Unit provided to UnitInfoPanel invalid !")
	
	
	#placeholderTarget.stats = Stats.new()
	#placeholderTarget.stats.experience = 220
	#placeholderTarget.position = Vector2(500.0,100.0)
	#get_tree().root.add_child.call_deferred(placeholderTarget)
	
	#set_unit.call_deferred(placeholderTarget)
	var tab_bar : TabBar = $VBoxContainer/TabContainer.get_tab_bar()
	tab_bar.mouse_filter = Control.MOUSE_FILTER_PASS

func _get_stats() -> Stats:
	if unit is BaseUnit: return unit.stats
	if unit is UnitData: return unit.stats
	return null

func _get_display_name() -> String:
	return unit.display_name

func _get_icon() -> Texture2D:
	return unit.icon

func _get_weapon():
	if unit is BaseUnit: return unit.weapon
	if unit is UnitData: return unit.weapon
	return null

# Live unit setup
func _setup_live(target: BaseUnit) -> void:
	_populate_shared()
	_populate_live_only()
	
	# connect live unit signals
	target.stats.stats_recalculated.connect(_on_stats_changed)
	target.stats.health_changed.connect(_on_health_changed)
	target.stats.shield_changed.connect(_on_shield_changed)
	target.stats.exp_changed.connect(_on_experience_changed.unbind(2))
	target.statusEffectModule.effects_changed.connect(set_status_effects)
	target.weapon_changed.connect(set_gear)
	target.armor_changed.connect(set_gear)
	target.accessories_changed.connect(set_gear)

# UnitData setup 
func _setup_data(_target: UnitData) -> void:
	_populate_shared()
	_hide_live_only_elements()
	
	# data signals connections
	_target.stats.stats_recalculated.connect(_on_stats_changed)
	var unit_stats := _get_stats()
	_apply_unit_data_buffs(unit_stats)

func _populate_shared() -> void:
	iconRect.texture = _get_icon()
	iconRect.modulate = unit.color if unit is UnitData else unit.sprite_color
	nameLabel.text = _get_display_name()
	descriptionLabel.text = unit.description
	levelLabel.text = "Lv. %d" % _get_stats().level
	set_overview_text()
	set_gear()
	set_stats_view()

func _populate_live_only() -> void:
	unit_health_label.visible = true
	unit_shield_label.visible = true
	set_health()
	set_status_effects()

func _hide_live_only_elements() -> void:
	unit_health_label.visible = false
	unit_shield_label.visible = false
	# hide status effects section too

func set_info() ->void :
	iconRect.texture = unit.icon if unit.icon else null
	nameLabel.text = unit.display_name
	typeLabel.text = "Unit type : " + unit.get_class()
	
	descriptionLabel.text = unit.description

func set_health() -> void :
	unit_health_label.text = "Health : x / y"

func set_experience() -> void:
	levelLabel.text = "Unit Level : " + str(unit.stats.level)

func _on_stats_changed() -> void :
	print("Stats changed")
	set_info()   # for name and info
	set_overview_text()  # for stats
	set_stats_view()  # refresh stats view

func _on_experience_changed() -> void :
	print("updating %s exp display" % [unit.display_name])
	set_experience()
	pass

func clear_gear() -> void :
	pass
	for c in gear_vbox_container.get_children() :
		c.queue_free()

func set_gear() -> void :
	clear_gear()
	
	var stats := _get_stats()
	var weapon = unit.weapon
	var armor = unit.armor if "armor" in unit else null
	var accessories = unit.accessories if "accessories" in unit else []
	var accessory_limit = stats.current_accessory_limit if stats else 0
	
	var weapon_container : GearContainer = GEAR_CONTAINER.instantiate()
	weapon_container.gear = weapon
	##armor_slot.owner_unit = unit if unit is BaseUnit else null
	gear_vbox_container.add_child(weapon_container)
	
	if armor :
		var armor_container : GearContainer = GEAR_CONTAINER.instantiate()
		armor_container.gear = armor
		##armor_slot.owner_unit = unit if unit is BaseUnit else null
		gear_vbox_container.add_child(armor_container)
	
	
	if accessories != [] :
		for i in accessory_limit:
			var acc_container : GearContainer = GEAR_CONTAINER.instantiate()
			acc_container.gear = accessories[i] if i < accessories.size() else null
			##armor_slot.owner_unit = unit if unit is BaseUnit else null
			gear_vbox_container.add_child(acc_container)

@onready var overview_rich_text_label: RichTextLabel = %OverviewRichTextLabel
@onready var overview_v_box_container: VBoxContainer = %OverviewVBoxContainer

func set_overview_text() -> void :
	var unit_stats : Stats = _get_stats()
	for row in overview_v_box_container.get_children() :
		if row is HBoxContainer :
			row.queue_free()
	overview_rich_text_label.clear()
	overview_rich_text_label.append_text("[fill]")
	var attributes := [
		["Strength .............", unit_stats.current_strength, unit_stats.base_strength,Stats.Attributes.STRENGTH],
		["Dexterity ............", unit_stats.current_dexterity, unit_stats.base_dexterity,Stats.Attributes.DEXTERITY],
		["Endurance ..........", unit_stats.current_endurance, unit_stats.base_endurance,Stats.Attributes.ENDURANCE],
		["Intelligence ........", unit_stats.current_intellect, unit_stats.base_intellect,Stats.Attributes.INTELLECT],
		["Faith ....................", unit_stats.current_faith, unit_stats.base_faith,Stats.Attributes.FAITH],
		["Attunement .......", unit_stats.current_attunement, unit_stats.base_attunement,Stats.Attributes.ATTUNEMENT],
		]
	
	for attr in attributes:
		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = attr[0]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		
		var attribute_name : String = attr[0]
		var current: int = attr[1]
		var base: int = attr[2]
		var bonus: int = current - base
		var bonus_str := "       "
		var value_label := RichTextLabel.new()
		value_label.bbcode_enabled = true
		value_label.fit_content = true
		value_label.scroll_active = false
		value_label.custom_minimum_size.x = 80
		value_label.append_text(str(current)) 
		if bonus > 0:
			value_label.append_text("([color=green]+%d[/color])" % [bonus])
		elif bonus < 0:
			value_label.append_text("([color=red]%d[/color])" % [bonus])
		row.add_child(value_label)
		
		if unit_stats.attribute_points_available > 0 :
			var plus_btn := Button.new()
			plus_btn.text = "+"
			plus_btn.add_theme_font_size_override("font_size",8)
			plus_btn.custom_minimum_size = Vector2(16, 16)
			var stat_attr: Stats.Attributes = attr[3]
			plus_btn.pressed.connect(func():
				unit_stats.spend_attribute_point(stat_attr)
				set_overview_text())
			row.add_child(plus_btn)
		
		overview_v_box_container.add_child(row)
		overview_v_box_container.move_child(row,0)
	
	overview_rich_text_label.append_text("[/fill]")
	
	overview_rich_text_label.append_text("\nAvailable points : %s\n" % unit_stats.attribute_points_available)

func _apply_unit_data_buffs(unit_stats: Stats) -> void :
	unit_stats.stat_buffs.clear()
	if unit.weapon:
		unit.weapon.apply_owner_buffs(unit_stats)
		if unit is BaseUnit :
			unit.weapon.owner = unit
			unit.weapon.setup_stats()
	if unit.armor:
		unit.armor.apply_owner_buffs(unit_stats)
	if unit.accessories != []:
		for acc in unit.accessories:
			if acc:
				acc.apply_owner_buffs(unit_stats)

func set_status_effects() ->void :
	pass

func _on_health_changed(health : float,max_health : float) -> void :
	unit_health_label.text = "Health : %d / %d" % [health,max_health]

func _on_shield_changed(shield : float,max_shield : float) -> void :
	unit_shield_label.text = "Shield : %d / %d" % [shield,max_shield]

func _on_close_button_pressed() -> void:
	queue_free()

func _on_tab_container_tab_changed(_tab: int) -> void:
	await get_tree().process_frame
	reset_size()

func set_stats_view() -> void :
	clear_stat_entries()
	fill_stat_entries()

func clear_stat_entries() -> void :
	for c in %StatEntriesContainer.get_children() :
		c.queue_free()

func fill_stat_entries() -> void :
	var unit_stats :Stats = _get_stats()
	var attributeLabel : RichTextLabel = RichTextLabel.new()
	attributeLabel.bbcode_enabled = true
	attributeLabel.fit_content = true
	attributeLabel.scroll_active = false
	attributeLabel.text = "[font_size=18] Attributes [/font_size]"
	%StatEntriesContainer.add_child(attributeLabel)
	
	for stat in unit.stats.Attributes :
		var new_row := STAT_ENTRY_ROW.instantiate()
		var row_entry_name : RichTextLabel = new_row.find_child("StatEntryName")
		var row_entry_value : RichTextLabel = new_row.find_child("StatEntryValue")
		row_entry_name.text = str(stat).capitalize()
		row_entry_value.text = str(unit_stats.get_current_stat(Stats.BuffableStats.get(stat)))
		new_row.gui_input.connect(func(event):
			if event.is_action_pressed("left_mouse"):
				if not row_entry_name.has_theme_constant_override("outline_size") :
					clear_entries_outline() 
					row_entry_name.add_theme_constant_override("outline_size",1)
					row_entry_value.add_theme_constant_override("outline_size",1)
				update_stat_details(Stats.BuffableStats.get(stat)))
		%StatEntriesContainer.add_child(new_row)
	
	var statLabel : RichTextLabel = RichTextLabel.new()
	statLabel.bbcode_enabled = true
	statLabel.fit_content = true
	statLabel.scroll_active = false
	statLabel.text = "[font_size=18] Other stats [/font_size]"
	%StatEntriesContainer.add_child(statLabel)
	
	for stat in unit.stats.BuffableStats :
		if stat in unit.stats.Attributes :
			continue
		var new_row := STAT_ENTRY_ROW.instantiate()
		var row_entry_name : RichTextLabel = new_row.find_child("StatEntryName")
		var row_entry_value : RichTextLabel = new_row.find_child("StatEntryValue")
		row_entry_name.text = str(stat).capitalize()
		row_entry_value.text = str(unit_stats.get_current_stat(Stats.BuffableStats.get(stat)))
		new_row.gui_input.connect(func(event):
			if event.is_action_pressed("left_mouse"):
				if not row_entry_name.has_theme_constant_override("outline_size") :
					clear_entries_outline() 
					row_entry_name.add_theme_constant_override("outline_size",1)
					row_entry_value.add_theme_constant_override("outline_size",1)
				update_stat_details(Stats.BuffableStats.get(stat)))
		%StatEntriesContainer.add_child(new_row)

func clear_entries_outline() -> void:
	for row in %StatEntriesContainer.get_children() :
		var row_entry_name : RichTextLabel = row.find_child("StatEntryName")
		var row_entry_value : RichTextLabel = row.find_child("StatEntryValue")
		if row_entry_name and row_entry_value :
			row_entry_name.remove_theme_constant_override("outline_size")
			row_entry_value.remove_theme_constant_override("outline_size")

func update_stat_details(stat: Stats.BuffableStats) -> void :
	var unit_stats : Stats = _get_stats()
	var stat_name : String = Stats.BuffableStats.keys()[stat].capitalize()
	var description : String = Stats.stat_descriptions.get(stat, "No description available.")
	var current_value := unit_stats.get_current_stat(stat)
	var base_value : float = unit_stats.get(str("base_") + Stats.BuffableStats.keys()[stat].to_lower())
	var bonus := current_value - float(base_value) if base_value != null else 0.0
	
	stat_details_label.clear()
	stat_details_label.append_text("[center][font_size=20] "+stat_name+" [/font_size][/center]")
	stat_details_label.append_text("\n\n"+description)
	stat_details_label.append_text("\n\n[b] Total : %s [/b]" % current_value)
	stat_details_label.append_text("\n\tbase value : %s" % base_value)
	stat_details_label.append_text("\n\tbonuses : %s" % bonus)
	#Add details to source of the bonuses later down the line
	#stat_details_label.append_text("\n\tscaling bonuses : %s")
	#stat_details_label.append_text("\n\tstatus effects changes : %s")
	#stat_details_label.append_text("\n\tother changes : %s")
	
	
	
	
	

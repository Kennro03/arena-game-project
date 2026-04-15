extends Tooltip
class_name UnitTooltip

var unit_data : UnitData = preload("res://ressources/Units/unit_data/Pablo.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	text_label.text = ""
	if unit_data == null :
		printerr("No unit_data provided to spawn tooltip !!")
	setup(unit_data)

func setup(unit: UnitData) -> void:
	add_unit_name(unit)
	add_unit_type(unit)
	#add_weapon_description(weapon)
	add_unit_attributes(unit)
	

func add_unit_name(unit: UnitData) -> void:
	text_label.append_text("[center][font_size=10]%s[/font_size][/center]" % [unit.display_name])
	text_label.newline()

func add_unit_type(unit: UnitData) -> void :
	var unit_type: String = unit.get_script().get_global_name().trim_suffix("UnitData").capitalize()
	var line: String = "[i][color=light_gray]%s[/color][/i]" % [unit_type]
	text_label.append_text(line)
	text_label.newline()

func add_unit_description(unit: UnitData) -> void :
	var unit_description: String = unit.description
	var line: String = "%s" % [unit_description]
	text_label.append_text(line)
	text_label.newline()

func add_unit_attributes(unit: UnitData) -> void:
	var attributes := {
		"Strength": unit.stats.current_strength,
		"Dexterity": unit.stats.current_dexterity,
		"Endurance": unit.stats.current_endurance,
		"Intellect": unit.stats.current_intellect,
		"Faith": unit.stats.current_faith,
		"Attunement": unit.stats.current_attunement,
	}
	text_label.append_text("[b]Unit Attributes :[/b]")
	text_label.newline()
	for attribute_name in attributes :
		text_label.append_text("%s - %s" % [attribute_name,attributes[attribute_name]])
		text_label.newline()

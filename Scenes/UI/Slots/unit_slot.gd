extends Slot
class_name UnitSlot

@export var _unit_data: UnitData = null
@onready var drag_visual: SlotDragVisual = %DragVisual

func set_unit(_unit: UnitData) -> void:
	_unit_data = _unit
	if _unit_data != null :
		icon_sprite.modulate = _unit_data.color  
		drag_visual.enabled = true
	else : 
		drag_visual.enabled = false
	set_visuals()

func get_icon() -> Texture2D:
	if _unit_data :
		if _unit_data.icon :
			return _unit_data.icon  
		else : 
			var placeholder_fallback_texture : PlaceholderTexture2D = PlaceholderTexture2D.new()
			placeholder_fallback_texture.size = Vector2(32.0,32.0)
			return placeholder_fallback_texture
	else  :
		return null

func get_border() -> Texture2D:
	return null  # no rarity border for units

func _make_custom_tooltip(_for_text: String) -> Object:
	if _unit_data == null:
		return null
	
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.custom_minimum_size = Vector2(150, 30)
	
	_add_unit_name(rtl, _unit_data)
	_add_unit_type(rtl, _unit_data)
	_add_unit_attributes(rtl, _unit_data)
	
	return rtl

func _add_unit_name(_rtl: RichTextLabel, unit: UnitData) -> void:
	_rtl.append_text("[center][font_size=24]%s[/font_size][/center]" % [unit.display_name])
	_rtl.newline()

func _add_unit_type(_rtl: RichTextLabel, unit: UnitData) -> void :
	var unit_type: String = unit.get_script().get_global_name().trim_suffix("UnitData").capitalize()
	var line: String = "[color=light_gray]%s[/color]" % [unit_type]
	_rtl.append_text(line)
	_rtl.newline()

func _add_unit_description(_rtl: RichTextLabel, unit: UnitData) -> void :
	var unit_description: String = unit.description
	var line: String = "%s" % [unit_description]
	_rtl.append_text(line)
	_rtl.newline()

func _add_unit_attributes(_rtl: RichTextLabel, unit: UnitData) -> void:
	var attributes := {
		"Strength": unit.stats.current_strength,
		"Dexterity": unit.stats.current_dexterity,
		"Endurance": unit.stats.current_endurance,
		"Intellect": unit.stats.current_intellect,
		"Faith": unit.stats.current_faith,
		"Attunement": unit.stats.current_attunement,
	}
	_rtl.append_text("[center]Unit Attributes :[/center]")
	_rtl.newline()
	for attribute_name in attributes :
		_rtl.append_text("%s : %s" % [attribute_name,attributes[attribute_name]])
		_rtl.newline()

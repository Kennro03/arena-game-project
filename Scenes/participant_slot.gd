extends Slot
class_name ParticipantSlot

var _fighter_data: FighterData = null

signal fighter_changed(slot: ParticipantSlot)
signal export_requested(slot: ParticipantSlot)
signal remove_requested(slot: ParticipantSlot)

const CONFIRMATION_POPUP = preload("uid://uhruds3j3j6v")

func set_fighter(fighter: FighterData) -> void:
	_fighter_data = fighter
	if fighter != null and fighter.unit_data != null:
		icon_sprite.modulate = fighter.unit_data.color
	set_visuals()
	fighter_changed.emit(self)

func get_fighter() -> FighterData:
	return _fighter_data

func has_fighter() -> bool:
	return _fighter_data != null and _fighter_data.unit_data != null

func get_icon() -> Texture2D:
	if _fighter_data and _fighter_data.unit_data:
		return _fighter_data.unit_data.icon if _fighter_data.unit_data.icon \
			   else PlaceholderTexture2D.new()
	return null

func get_border() -> Texture2D:
	return null

func _make_custom_tooltip(_for_text: String) -> Object:
	if _fighter_data == null:
		return null
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.custom_minimum_size = Vector2(180, 30)
	_add_fighter_header(rtl)
	_add_fighter_record(rtl)
	_add_fighter_archetype(rtl)
	_add_fighter_attributes(rtl)
	panel.add_child(rtl)
	return panel

func _add_fighter_header(rtl: RichTextLabel) -> void:
	var _name := _fighter_data.unit_data.display_name if _fighter_data.unit_data else "Unknown"
	rtl.append_text("[center][font_size=20]%s[/font_size][/center]\n" % _name)
	rtl.append_text("[center][color=gray]ID: %s[/color][/center]\n" % _fighter_data.arena_id)

func _add_fighter_record(rtl: RichTextLabel) -> void:
	rtl.append_text("\nFights: %d 
	[color=green]W: %d[/color]  [color=red]L: %d[/color]  [color=yellow]D: %d[/color]\n" % 
	[_fighter_data.fights_count, 
	_fighter_data.wins, _fighter_data.losses, _fighter_data.draws])

func _add_fighter_archetype(rtl: RichTextLabel) -> void:
	if _fighter_data.stat_archetype:
		rtl.append_text("Stat: [color=cyan]%s[/color]\n" % _fighter_data.stat_archetype.archetype_name)
	if not _fighter_data.tag_priority.is_empty():
		rtl.append_text("Tags: [color=orange]%s[/color]\n" % ", ".join(_fighter_data.tag_priority))

func _add_fighter_attributes(rtl: RichTextLabel) -> void:
	if _fighter_data.unit_data == null:
		return
	var stats := _fighter_data.unit_data.stats
	rtl.append_text("Lv.%d
	STR : %d | DEX : %d | END : %d
	INT : %d | FAI : %d | ATT : %d" % [
		stats.level,
		stats.current_strength, stats.current_dexterity, stats.current_endurance,
		stats.current_intellect, stats.current_faith, stats.current_attunement])

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT and has_fighter():
			_show_context_menu()
			accept_event()

func _show_context_menu() -> void:
	var popup := PopupMenu.new()
	popup.add_item("Inspect Fighter", 0)
	popup.add_separator()
	popup.add_item("Remove", 1)
	popup.add_separator()
	popup.add_item("Export...", 2)
	popup.id_pressed.connect(func(id):
		match id:
			0: if _fighter_data.unit_data: Events.open_unit_info_requested.emit(_fighter_data.unit_data)
			1: remove_requested.emit()
			2: export_requested.emit()
		popup.queue_free())
	add_child(popup)
	popup.popup(Rect2(get_global_mouse_position(), Vector2.ZERO))

func _confirm_remove() -> void:
	var popup := CONFIRMATION_POPUP.instantiate() as ConfirmationPopup
	popup.setup("Remove Fighter", "Remove %s from the roster?" % _fighter_data.unit_data.display_name)
	get_tree().root.add_child(popup)
	popup.confirmed.connect(func(result):
		if result:
			remove_requested.emit(self))

func set_highlighted(value: bool) -> void:
	if value:
		add_theme_stylebox_override("panel", _highlighted_style())
	else:
		remove_theme_stylebox_override("panel")

func _highlighted_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.85, 0.2, 0.25)
	style.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style.set_border_width_all(2)
	return style

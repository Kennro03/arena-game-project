extends Control
class_name LevelupCardSelection

const LEVELUP_CARD = preload("uid://uqx7nxukdpip")

@export_group("Testing")
@export var test_in_editor: bool = false:
	set(value):
		test_in_editor = value
		if value and is_node_ready():
			_setup_test()
@export var test_draw_type: DrawSchedule.DrawType = DrawSchedule.DrawType.PASSIVE_SKILL
@export var test_rerolls: int = 1

@onready var card_container: HBoxContainer = %CardContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var title_label: RichTextLabel = %TitleLabel
@onready var select_random_button: Button = %SelectRandomButton
@onready var cancel_selection_button: Button = %CancelSelectionButton

var _unit = null
var _draw_type: DrawSchedule.DrawType
var _current_pool: Array[LevelupCardData] = []
var _rerolls_remaining: int = 1
var _cards_to_show: int = 3

func _ready() -> void:
	if test_in_editor or (Engine.is_editor_hint() == false and _unit == null):
		_setup_test()

func setup(unit, draw_type: DrawSchedule.DrawType, rerolls: int = 1) -> void:
	_unit = unit
	_draw_type = draw_type
	_rerolls_remaining = rerolls
	_update_title()
	_roll_cards()
	#animation_player.play("show")

func _setup_test() -> void:
	var dummy := UnitData.new()
	dummy.display_name = "Test Unit"
	dummy.stats = Stats.new()
	dummy.stats.setup_stats()
	
	dummy.stats.base_strength = 10
	dummy.stats.base_dexterity = 10
	dummy.stats.recalculate_stats()
	
	setup(dummy, test_draw_type, test_rerolls)

func _update_title() -> void:
	match _draw_type:
		DrawSchedule.DrawType.ACTIVE_SKILL:
			title_label.text = "[wave amp=40.0 freq=3.0 connected=1] Select an %s for %s" % ["Active skill",_unit.display_name]
		DrawSchedule.DrawType.PASSIVE_SKILL:
			title_label.text = "[wave amp=40.0 freq=3.0 connected=1] Select a %s card for %s" % ["Passive skill",_unit.display_name]
		DrawSchedule.DrawType.STAT_BONUS:
			title_label.text = "[wave amp=40.0 freq=3.0 connected=1] Select a %s card for %s" % ["Bonus",_unit.display_name]

func _roll_cards() -> void:
	_clear_cards()
	if _unit is BaseUnit:
		_current_pool = CardPoolGenerator.generate_pool(_unit, _draw_type, _cards_to_show)
	else:
		_current_pool = CardPoolGenerator.generate_pool_for_data(_unit, _draw_type, _cards_to_show)
	for card_data in _current_pool:
		_spawn_card(card_data)

func _spawn_card(card_data: LevelupCardData) -> void:
	var card := LEVELUP_CARD.instantiate() as LevelupCard
	card_container.add_child(card)
	card.setup(card_data, _rerolls_remaining > 0)
	card.card_clicked.connect(func(): _card_selected(card_data))
	card.card_reroll_clicked.connect(func(): _on_reroll_pressed(card))

func _clear_cards() -> void:
	for c in card_container.get_children():
		c.queue_free()

func _card_selected(card_data: LevelupCardData) -> void:
	print("Card selected: %s" % card_data.display_name)
	if _unit is BaseUnit or _unit is UnitData:
		_unit.apply_draw(card_data)
	else:
		print("Test mode — card not applied to any unit")
	await get_tree().process_frame  # replace animation await for now
	queue_free()

#used for automatic card selection 
func get_random_card() -> LevelupCardData:
	print("Choosing random card")
	return _current_pool.pick_random()

#used for automatic card selection 
func get_random_card_by_tags(tags: Array[String]) -> LevelupCardData :
	print("Choosing random card")
	var correctly_tagged_cards : Array[LevelupCardData] = []
	for searched_tag in tags :
		for card_data in _current_pool :
			if card_data.get_tags().has(searched_tag) and not correctly_tagged_cards.has(card_data) :
				correctly_tagged_cards.append(card_data)
	if correctly_tagged_cards.size() >= 1 :
		return correctly_tagged_cards.pick_random()
	return null

func _on_reroll_pressed(card: LevelupCard) -> void:
	if _rerolls_remaining <= 0:
		return
	_rerolls_remaining -= 1
	
	# generate one new card to replace this one
	var excluded: Array[LevelupCardData] = []
	for c in card_container.get_children():
		excluded.append((c as LevelupCard)._card_data)
	
	print("Excluded = {")
	for card_data in excluded :
		print("    " + card_data.display_name)
	print("}")
	
	var new_pool := CardPoolGenerator.generate_pool_excluding(_unit, _draw_type, 1, excluded)
	
	print("New pool = {")
	for card_data in new_pool :
		print("    " + card_data.display_name)
	print("}")
	
	if new_pool.is_empty():
		return
	
	var new_data := new_pool[0]
	var index := card.get_index()
	card.queue_free()
	
	# spawn replacement at same position
	var new_card := LEVELUP_CARD.instantiate() as LevelupCard
	card_container.add_child(new_card)
	card_container.move_child(new_card, index)
	new_card.setup(new_data, _rerolls_remaining > 0)
	new_card.card_clicked.connect(func(): _card_selected(new_data))
	new_card.card_reroll_clicked.connect(func(): _on_reroll_pressed(new_card))
	
	# refresh reroll button visibility on all remaining cards
	_refresh_reroll_buttons()

func _refresh_reroll_buttons() -> void:
	for c in card_container.get_children():
		(c as LevelupCard).set_reroll_visible(_rerolls_remaining > 0)

func _on_select_random_button_pressed() -> void:
	_card_selected(get_random_card()) 

func _on_cancel_selection_button_pressed() -> void:
	# cancel the card selection without consuming the unit's draw
	queue_free()

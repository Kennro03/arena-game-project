extends Control
class_name LevelupCardSelection


const LEVELUP_CARD = preload("uid://uqx7nxukdpip")

@onready var background: CanvasLayer = %Background
@onready var ui: CanvasLayer = %UI
@onready var card_container: HBoxContainer = %CardContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var title_label: RichTextLabel = %TitleLabel

var _unit: BaseUnit = null
var _draw_type: DrawSchedule.DrawType
var _current_pool: Array[LevelupCardData] = []
var _rerolls_remaining: int = 1
var _cards_to_show: int = 3

func setup(unit: BaseUnit, draw_type: DrawSchedule.DrawType, rerolls: int = 1) -> void:
	_unit = unit
	_draw_type = draw_type
	_rerolls_remaining = rerolls
	_update_title()
	_roll_cards()
	#animation_player.play("show")

func _update_title() -> void:
	match _draw_type:
		DrawSchedule.DrawType.ACTIVE_SKILL:
			title_label.text = "Choose an Active Skill"
		DrawSchedule.DrawType.PASSIVE_SKILL:
			title_label.text = "Choose a Passive Skill"
		DrawSchedule.DrawType.STAT_BONUS:
			title_label.text = "Choose a Bonus"

func _roll_cards() -> void:
	_clear_cards()
	_current_pool = CardPoolGenerator.generate_pool(_unit, _draw_type, _cards_to_show)
	for card_data in _current_pool:
		_spawn_card(card_data)

func _spawn_card(card_data: LevelupCardData) -> void:
	var card := LEVELUP_CARD.instantiate() as LevelupCard
	card_container.add_child(card)
	card.setup(card_data, _rerolls_remaining > 0)
	card.card_clicked.connect(func(): _on_card_selected(card_data))
	card.card_reroll_clicked.connect(func(): _on_reroll_pressed(card))

func _clear_cards() -> void:
	for c in card_container.get_children():
		c.queue_free()

func _on_card_selected(card_data: LevelupCardData) -> void:
	_apply_card(card_data)
	animation_player.play("hide")
	await animation_player.animation_finished
	queue_free()

func _apply_card(card_data: LevelupCardData) -> void:
	match card_data.card_type:
		LevelupCardData.CardType.ACTIVE_SKILL, LevelupCardData.CardType.PASSIVE_SKILL:
			if card_data.skill:
				_unit.skillModule.add_skill(card_data.skill)
		LevelupCardData.CardType.STAT_BONUS:
			if card_data.stat_buff:
				_unit.stats.add_buff(card_data.stat_buff)
				_unit.stats.recalculate_stats()

func _on_reroll_pressed(card: LevelupCard) -> void:
	if _rerolls_remaining <= 0:
		return
	_rerolls_remaining -= 1
	
	# generate one new card to replace this one
	var excluded := card_container.get_children()\
		.filter(func(c): return c != card)\
		.map(func(c): return (c as LevelupCard)._card_data)
	var new_pool := CardPoolGenerator.generate_pool_excluding(_unit, _draw_type, 1, excluded)
	
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
	new_card.card_clicked.connect(func(): _on_card_selected(new_data))
	new_card.card_reroll_clicked.connect(func(): _on_reroll_pressed(new_card))
	
	# refresh reroll button visibility on all remaining cards
	_refresh_reroll_buttons()

func _refresh_reroll_buttons() -> void:
	for c in card_container.get_children():
		(c as LevelupCard).set_reroll_visible(_rerolls_remaining > 0)

extends Control
class_name ExpeditionSelection

const CARD_SPACING := 400
const SELECTED_SCALE := Vector2(1.2, 1.2)
const NORMAL_SCALE := Vector2(1.0, 1.0)

@export var expedition_scene : StringName = &""

@onready var ui: CanvasLayer = %UI
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var background: CanvasLayer = %Background
@onready var left: Button = %Left
@onready var right: Button = %Right
@onready var cards_container: Control = %CardContainer

const EXPEDITION_CARD := preload("res://Scenes/Expedition/expedition_card.tscn")

var cards: Array[Control] = []
var selected_index: int = 0
var expeditions: Array[ExpeditionData] = [
	]

func _ready() -> void:
	Player.ui_layer = ui
	Player.current_scene = "uid://tv3sqx07krda"
	
	_load_expedition_data()
	_build_cards()
	_update_cards()

func _load_expedition_data() -> void :
	var dir := DirAccess.open("res://ressources/Expeditions/")
	for file in dir.get_files():
		if file.get_extension() == "tres":
			expeditions.append(load("res://ressources/Expeditions/" + file))

func _build_cards() -> void:
	for expedition in expeditions:
		var card := EXPEDITION_CARD.instantiate()
		card.expedition_data = expedition
		cards_container.add_child(card)
		cards.append(card)
		card.connect("expedition_selected",_on_expedition_selected)

func _update_cards() -> void:
	var center_x := cards_container.size.x / 2.0
	for i in cards.size():
		var card := cards[i]
		var offset := i - selected_index
		var target_x := center_x + offset * CARD_SPACING - card.size.x / 2.0
		var target_scale := SELECTED_SCALE if i == selected_index else NORMAL_SCALE
		
		var tween := create_tween().set_parallel(true)
		tween.tween_property(card, "position:x", target_x, 0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "scale", target_scale, 0.2).set_ease(Tween.EASE_OUT)
		card.z_index = 1 if i == selected_index else 0

func scroll_left() -> void:
	if selected_index > 0:
		selected_index -= 1
		_update_cards()

func scroll_right() -> void:
	if selected_index < cards.size() - 1:
		selected_index += 1
		_update_cards()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("right") :
		scroll_right()
	elif Input.is_action_just_pressed("left") :
		scroll_left()

func _on_expedition_selected(_expedition_card : ExpeditionCard) -> void :
	print("Expedition %s selected" % _expedition_card.expedition_data.ExpeditionName)
	Player.pending_expedition = _expedition_card.expedition_data
	Player.go_to_scene(expedition_scene)

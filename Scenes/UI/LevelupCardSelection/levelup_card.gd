extends Panel
class_name LevelupCard

signal card_clicked()
signal card_reroll_clicked()

@onready var title: RichTextLabel = %Title
@onready var icon_rect: TextureRect = %ImageRect
@onready var description: RichTextLabel = %Description
@onready var reroll_button: Button = %RerollButton

var _card_data: LevelupCardData = null

func setup(card_data: LevelupCardData, show_reroll: bool = true) -> void:
	_card_data = card_data
	title.text = card_data.display_name
	description.text = card_data.description
	icon_rect.texture = card_data.icon
	reroll_button.visible = show_reroll

func _on_reroll_button_pressed() -> void:
	card_reroll_clicked.emit()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if reroll_button.visible and reroll_button.get_global_rect().has_point(get_global_mouse_position()):
			return
		card_clicked.emit()
		accept_event()

func set_reroll_visible(_visible: bool) -> void:
	reroll_button.visible = _visible

func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1,1.1), 0.1).set_trans(Tween.TRANS_CUBIC)

func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.1).set_trans(Tween.TRANS_CUBIC)

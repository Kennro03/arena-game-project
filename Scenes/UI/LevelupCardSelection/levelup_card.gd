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
		card_clicked.emit()
		accept_event()

func set_reroll_visible(_visible: bool) -> void:
	reroll_button.visible = _visible

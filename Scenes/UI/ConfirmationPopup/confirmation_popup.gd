extends Control
class_name ConfirmationPopup

signal confirmed(result: bool)

@onready var title_label: RichTextLabel = %Title
@onready var body_label: RichTextLabel = %Body

var popup_title : String = ""
var popup_body : String = ""

func setup(title: String, body: String) -> ConfirmationPopup:
	popup_title = title
	popup_body = body
	return self

func _ready() -> void:
	if popup_title.is_empty() or popup_body.is_empty():
		printerr("ConfirmationPopup: missing title or body")
		queue_free()
		return
	title_label.text = popup_title
	body_label.text = popup_body

func _on_confirm_button_pressed() -> void:
	confirmed.emit(true)
	queue_free()

func _on_cancel_button_pressed() -> void:
	confirmed.emit(false)
	queue_free()

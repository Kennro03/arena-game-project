extends Panel
class_name ExpeditionCard

signal expedition_selected(card:ExpeditionCard)

@onready var title: RichTextLabel = %Title
@onready var image_rect: TextureRect = %ImageRect
@onready var description: RichTextLabel = %Description
@onready var embark_button: Button = %EmbarkButton

@export var expedition_data : ExpeditionData

func _ready() -> void:
	if expedition_data == null :
		printerr("No expedition data for card !")
		return
	title.text = expedition_data.ExpeditionName
	description.text = expedition_data.ExpeditionDescription
	image_rect.texture = expedition_data.ExpeditionIcon

func _on_embark_button_pressed() -> void:
	expedition_selected.emit(self)

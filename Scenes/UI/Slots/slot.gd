extends Panel
class_name Slot

@onready var icon_sprite: Sprite2D = %SlotSprite
@onready var border_sprite: Sprite2D = %SlotBorder

const EMPTY_BORDER := preload("res://ressources/Sprites/UI/Borders/empty_border.png")

func _ready() -> void:
	set_visuals()

func set_visuals() -> void:
	set_texture()
	set_border()

func get_icon() -> Texture2D:
	return null  # overridden by subclass

func get_border() -> Texture2D:
	return EMPTY_BORDER  # overridden by subclass

func set_texture() -> void:
	var icon := get_icon()
	icon_sprite.texture = icon
	icon_sprite.visible = icon != null

func set_border() -> void:
	border_sprite.texture = get_border()

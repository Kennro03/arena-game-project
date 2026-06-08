extends Panel
class_name Slot

signal slot_hovered(slot: Slot)
signal slot_unhovered(slot: Slot)
signal slot_clicked(slot: Slot, button: int)

@onready var icon_sprite: TextureRect = %SlotSprite
@onready var border_sprite: TextureRect = %SlotBorder

const EMPTY_BORDER := preload("res://ressources/Sprites/UI/Borders/empty_border.png")

func _ready() -> void:
	set_visuals()

func _on_mouse_entered() -> void:
	slot_hovered.emit(self)

func _on_mouse_exited() -> void:
	slot_unhovered.emit(self)

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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(self, MOUSE_BUTTON_LEFT)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			Inspector.open(self)
			accept_event()

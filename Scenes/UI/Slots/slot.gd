extends Panel
class_name Slot

signal slot_hovered(slot: Slot)
signal slot_unhovered(slot: Slot)
signal slot_clicked(slot: Slot, button: int)

const item_tooltip_scene := preload("res://Scenes/UI/Tooltips/item_tooltip.tscn")
const weapon_tooltip_scene := preload("res://Scenes/UI/Tooltips/weapon_tooltip.tscn")
const unit_tooltip_scene := preload("res://Scenes/UI/Tooltips/unit_tooltip.tscn")

@onready var icon_sprite: Sprite2D = %SlotSprite
@onready var border_sprite: Sprite2D = %SlotBorder

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
		slot_clicked.emit(self, event.button_index)
		#accept_event()

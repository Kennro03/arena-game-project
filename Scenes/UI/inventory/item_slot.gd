extends Panel
class_name ItemSlot

@export var item : Item
@export var ItemIconSprite : Texture2D = null

@onready var item_sprite: Sprite2D = %ItemSprite
@onready var item_border: Sprite2D = %ItemBorder

const EMPTY_BORDER := preload("res://ressources/Sprites/UI/Borders/empty_border.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visuals()
	pass

func set_visuals() -> void : 
	set_texture()
	set_border()

func set_texture() -> void :
	if ItemIconSprite == null :
		return
	item_sprite.texture = ItemIconSprite

func set_border() -> void :
	if item :
		item_border.texture = item.item_borders[item.rarity]
	else :
		item_border.texture = EMPTY_BORDER

func set_item(_item: Item) -> void:
	item = _item
	if item:
		ItemIconSprite = item.icon
		item_sprite.visible = true
	else:
		ItemIconSprite = null
		item_sprite.visible = false
	set_visuals()

func _to_string() -> String:
	if item :
		return item.item_name
	else :
		return "empty"

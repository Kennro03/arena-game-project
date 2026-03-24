extends Panel
class_name ItemSlot

@export var item : Item
@export var ItemIconSprite : Texture2D = null
@export var SlotBorderSprite : Texture2D = null

@onready var item_sprite: Sprite2D = %ItemSprite
@onready var item_border: Sprite2D = %ItemBorder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_visuals()
	pass

func set_visuals() -> void : 
	set_texture()
	set_border()

func set_texture() -> void :
	if ItemIconSprite == null :
		printerr(("No item sprite"))
		return
	item_sprite.texture = ItemIconSprite

func set_border() -> void :
	if SlotBorderSprite == null :
		printerr(("No border"))
		return
	item_border.texture = SlotBorderSprite

func set_item(item: Item) -> void:
	self.item = item
	if item:
		ItemIconSprite.texture = item.icon
		ItemIconSprite.visible = true
	else:
		ItemIconSprite.texture = null
		ItemIconSprite.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

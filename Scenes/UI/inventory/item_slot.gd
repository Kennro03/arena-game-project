extends Slot
class_name ItemSlot

enum SlotContext { INVENTORY, UNIT_GEAR, REWARD, SHOP, DISPLAY }

var slot_context: SlotContext = SlotContext.DISPLAY
var owner_unit: BaseUnit = null  

@export var item: Item = null
@onready var drag_visual: SlotDragVisual = $DragVisual

@onready var rich_text_label: RichTextLabel = $TextLabel
@onready var text_label: RichTextLabel = $TextLabel

func set_item(_item: Item) -> void:
	item = _item
	set_visuals()
	if _item != null :
		drag_visual.enabled = true
	else : 
		drag_visual.enabled = false

func get_icon() -> Texture2D:
	return item.icon if item else null

func get_border() -> Texture2D:
	return item.item_borders[item.rarity] if item else EMPTY_BORDER

func _to_string() -> String:
	return item.item_name if item else "empty"

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	#print("Slot %s Entered" % [self.name])
	if item == null :
		return
	if item is Weapon :
		tooltip = weapon_tooltip_scene.instantiate()
		tooltip.wep = item
		#print("Requested weapon tooltip")
		Events.tooltip_requested.emit(tooltip)
	elif item is Accessory :
		tooltip = accessory_tooltip_scene.instantiate()
		tooltip.acc = item
		#print("Requested accessory tooltip")
		Events.tooltip_requested.emit(tooltip)
	else : 
		tooltip = item_tooltip_scene.instantiate()
		tooltip.item = item
		#print("Requested item tooltip")
		Events.tooltip_requested.emit(tooltip)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	#print("Slot %s left" % [self.name])
	if tooltip != null :
		tooltip.queue_free()
		tooltip = null

func set_label_text(new_text: String, font_size:int = 8) -> void :
	rich_text_label.append_text(new_text)
	rich_text_label.add_theme_font_size_override("normal_font_size",font_size)

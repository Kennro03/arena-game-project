extends Slot
class_name ItemSlot

@export var item: Item = null
@onready var drag_visual: SlotDragVisual = $DragVisual

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func set_item(_item: Item) -> void:
	item = _item
	set_visuals()

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
		Events.tooltip_requested.emit(tooltip)
	elif item is Accessory :
		tooltip = accessory_tooltip_scene.instantiate()
		tooltip.acc = item
		Events.tooltip_requested.emit(tooltip)
	else : 
		tooltip = item_tooltip_scene.instantiate()
		Events.tooltip_requested.emit(tooltip)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	#print("Slot %s left" % [self.name])
	if tooltip != null :
		tooltip.queue_free()
		tooltip = null

func set_label_text(new_text: String) -> void :
	rich_text_label.append_text(new_text)

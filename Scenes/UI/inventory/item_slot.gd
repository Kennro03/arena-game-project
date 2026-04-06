extends Slot
class_name ItemSlot

@export var item: Item = null
var tooltip : Tooltip = null

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
		self.add_child(tooltip)
		tooltip.setup(item)
	elif item is Accessory :
		tooltip = accessory_tooltip_scene.instantiate()
		self.add_child(tooltip)
		tooltip.setup(item)
	else : 
		tooltip = item_tooltip_scene.instantiate()
		self.add_child(tooltip)
		tooltip.setup(item)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	#print("Slot %s left" % [self.name])
	if tooltip != null :
		tooltip.queue_free()
		tooltip = null

extends Slot
class_name UnitSlot

@export var _unit_data: UnitData = null

func set_unit(_unit: UnitData) -> void:
	_unit_data = _unit
	set_visuals()

func get_icon() -> Texture2D:
	if _unit_data :
		if _unit_data.icon :
			return _unit_data.icon  
		else : 
			var placeholder_fallback_texture : PlaceholderTexture2D = PlaceholderTexture2D.new()
			placeholder_fallback_texture.size = Vector2(32.0,32.0)
			return placeholder_fallback_texture
	else  :
		return null

func get_border() -> Texture2D:
	return null  # no rarity border for units

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	#print("mouse entered ! ")
	if _unit_data != null : 
		print("data not null ! ")
		tooltip = unit_tooltip_scene.instantiate()
		tooltip.unit_data = _unit_data
		Events.tooltip_requested.emit(tooltip)

func _on_mouse_exited() -> void:
	Events.tooltip_cleared.emit()

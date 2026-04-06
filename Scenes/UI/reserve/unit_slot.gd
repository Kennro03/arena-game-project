extends Slot
class_name UnitSlot

@export var unit_data: UnitData = null

func set_unit(_unit: UnitData) -> void:
	unit_data = _unit
	set_visuals()

func get_icon() -> Texture2D:
	if unit_data :
		if unit_data.icon :
			return unit_data.icon  
		else : 
			var placeholder_fallback_texture : PlaceholderTexture2D = PlaceholderTexture2D.new()
			placeholder_fallback_texture.size = Vector2(32.0,32.0)
			return placeholder_fallback_texture
	else  :
		return null

func get_border() -> Texture2D:
	return null  # no rarity border for units

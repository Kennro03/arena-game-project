extends Control
class_name Status_Effect_Row

@onready var statusEffecticonRect := %IconTextureRect
@onready var statusEffectNameLabel := %StatusEffectNameLabel
@onready var statusEffectDescriptionLabel := %StatusEffectDescriptionLabel
@onready var propertiesList := %PropertiesVBoxContainer

@export var status_effect : StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if status_effect and status_effect.status_icon :
		statusEffecticonRect.texture = status_effect.status_icon  
	else :
		statusEffecticonRect.visible = false
	statusEffectNameLabel.text = status_effect.Status_effect_name if status_effect else "no status provided..."
	statusEffectDescriptionLabel.text = status_effect.Status_effect_description if status_effect else "no status provided..."
	
	set_properties_list(status_effect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_properties_list(status : StatusEffect)->void :
	if !status_effect :
		return
	for child in propertiesList.get_children():
		child.queue_free()
	var dict : Dictionary = status.get_relevant_properties()
	for property in dict.keys() :
		var row : PropertyLabel = PropertyLabel.new()
		row.add_theme_font_size_override("font_size",8)
		row.text = str(property) + " = " + str(dict[property])
		propertiesList.add_child(row)

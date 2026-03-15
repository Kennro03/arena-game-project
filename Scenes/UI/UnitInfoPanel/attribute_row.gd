extends HBoxContainer
class_name Attribute_Row

@onready var iconRect := $StatIcon
@onready var attributeNameLabel := $StatName
@onready var attributeValueLabel := $StatValue

@export var iconTexture : Texture2D
@export var attributeName : String
@export var attributeValue : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if iconTexture :
		iconRect.texture = iconTexture  
	else :
		iconRect.visible = false 
	attributeNameLabel.text = attributeName
	attributeValueLabel.text = attributeValue


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

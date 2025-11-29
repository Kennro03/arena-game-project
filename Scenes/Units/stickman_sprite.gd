extends Node2D

@export var headColor : Color = Color("White")
@export var armsColor : Color = Color("White")
@export var chestColor : Color = Color("White")
@export var handsColor : Color = Color("White")
@export var legsColor : Color = Color("White")
@export var feetColor : Color = Color("White")

func _ready() -> void:
	$HeadSprite.self_modulate = headColor
	$ArmsSprite.self_modulate = armsColor
	$ChestSprite.self_modulate = chestColor
	$HandsSprite.self_modulate = handsColor
	$LegsSprite.self_modulate = legsColor
	$FeetSprite.self_modulate = feetColor

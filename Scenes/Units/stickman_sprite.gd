extends Node2D

@export var bodyColor : Color = Color("White")
var headColor : Color = Color("White")
var armsColor : Color = Color("White")
var chestColor : Color = Color("White")
var handsColor : Color = Color("White")
var legsColor : Color = Color("White")
var feetColor : Color = Color("White")

func _ready() -> void:
	$HeadSprite.self_modulate = headColor
	$ArmsSprite.self_modulate = armsColor
	$ChestSprite.self_modulate = chestColor
	$HandsSprite.self_modulate = handsColor
	$LegsSprite.self_modulate = legsColor
	$FeetSprite.self_modulate = feetColor

extends Node2D

var flip : bool = false

@export var bodyColor : Color = Color("White")
var headColor : Color = Color("White")
var armsColor : Color = Color("White")
var chestColor : Color = Color("White")
var handsColor : Color = Color("White")
var legsColor : Color = Color("White")
var feetColor : Color = Color("White")

func _ready() -> void:
	$BodySprite.self_modulate = bodyColor
	$HeadSprite.self_modulate = headColor
	$ArmsSprite.self_modulate = armsColor
	$ChestSprite.self_modulate = chestColor
	$HandsSprite.self_modulate = handsColor
	$LegsSprite.self_modulate = legsColor
	$FeetSprite.self_modulate = feetColor

func flipSprite(flipped : bool) -> void :
	for sprite in get_children() :
		if sprite.get_class() == "Sprite2D" :
			if flip != flipped :
				sprite.flip_h = flipped
				flip = flipped

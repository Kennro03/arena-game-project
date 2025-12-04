extends Node2D

var flip : bool = false

@export var bodyColor : Color = Color("White")
var headColor : Color = Color("White")
var armsColor : Color = Color("White")
var chestColor : Color = Color("White")
var handsColor : Color = Color("White")
var legsColor : Color = Color("White")
var feetColor : Color = Color("White")

var lastAnimation : String = "None"
var idle_animations = ["idle"]
var fighting_animations = ["fighting"]
var dodge_animations = ["dodge1","dodge2"]
var cast_animations = []
var lightHit_animations = ["fist_light1","fist_light2"]
var heavyHit_animations = ["fist_heavy1"]
var specialHit_animations = []

func _ready() -> void:
	selfmodulate()

func selfmodulate() -> void : 
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

func play_idle_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if idle_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		$AnimationPlayer.play(idle_animations.pick_random(), -1, animationSpeed)

func play_fighting_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if fighting_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		$AnimationPlayer.play(fighting_animations.pick_random(), -1, animationSpeed)

func play_walk_animation(animationSpeed : float = 1.0):
	if animationSpeed != 1.0 :
		$AnimationPlayer.play("walk", -1, animationSpeed) 
	else : 
		$AnimationPlayer.play("walk", -1, randf_range(0.75,1.25))
	$AnimationPlayer.speed_scale = 1

func play_dodge_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if dodge_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		$AnimationPlayer.play(dodge_animations.pick_random(), -1, animationSpeed)

func play_cast_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if cast_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		$AnimationPlayer.play(cast_animations.pick_random(), -1, animationSpeed)

func play_lightHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if lightHit_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		if lastAnimation.ends_with("1") :
			$AnimationPlayer.play(lightHit_animations[0], -1, animationSpeed)
			lastAnimation = lightHit_animations[0]
		elif lastAnimation.ends_with("2") : 
			$AnimationPlayer.play(lightHit_animations[1], -1, animationSpeed)
			lastAnimation = lightHit_animations[1]
		else :
			$AnimationPlayer.play(lightHit_animations.pick_random(), -1, animationSpeed)

func play_heavyHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if heavyHit_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		$AnimationPlayer.play(heavyHit_animations.pick_random(), -1, animationSpeed)

func play_specialHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if specialHit_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		$AnimationPlayer.play(specialHit_animations.pick_random(), -1, animationSpeed)

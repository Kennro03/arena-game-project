extends Node2D
class_name StickmanSprite

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
@export var attack_animations := {
	Weapon.AttackTypeEnum.LIGHTATTACK: ["fist_light1", "fist_light2"],
	Weapon.AttackTypeEnum.HEAVYATTACK: ["fist_heavy1"],
	Weapon.AttackTypeEnum.SPECIALATTACK: []
}


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

func flipSprite(flipped: bool) -> void:
	if flip == flipped:
		return
	for sprite in get_children():
		if sprite is Sprite2D:
			sprite.flip_h = flipped
	flip = flipped

func play_idle_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if idle_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		var anim = idle_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)
		lastAnimation = anim

func play_fighting_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if fighting_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		var anim = fighting_animations.pick_random()
		$AnimationPlayer.play(fighting_animations.pick_random(), -1, animationSpeed)
		lastAnimation = anim

func play_walk_animation(animationSpeed : float = 1.0):
	if animationSpeed != 1.0 :
		$AnimationPlayer.play("walk", -1, animationSpeed) 
	else : 
		$AnimationPlayer.play("walk", -1, randf_range(0.75,1.25))
	$AnimationPlayer.speed_scale = 1
	lastAnimation = "walk"

func play_dodge_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if dodge_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		var anim = dodge_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)
		lastAnimation = anim

func play_cast_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if cast_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		var anim = cast_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)
		lastAnimation = anim

func play_lightHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		if lastAnimation.ends_with("1") :
			$AnimationPlayer.play(attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK][0], -1, animationSpeed)
			lastAnimation = attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK][0]
		elif lastAnimation.ends_with("2") : 
			$AnimationPlayer.play(attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK][1], -1, animationSpeed)
			lastAnimation = attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK][1]
		else :
			var anim = attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK].pick_random()
			$AnimationPlayer.play(anim, -1, animationSpeed)
			lastAnimation = anim

func play_heavyHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.HEAVYATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		var anim = attack_animations[Weapon.AttackTypeEnum.HEAVYATTACK].pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)
		lastAnimation = anim

func play_specialHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.SPECIALATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
		lastAnimation = animationName
	else : 
		var anim = attack_animations[Weapon.AttackTypeEnum.SPECIALATTACK].pick_random()
		$AnimationPlayer.play(attack_animations[Weapon.AttackTypeEnum.SPECIALATTACK].pick_random(), -1, animationSpeed)
		lastAnimation = anim

func play_attack_animation(attack_type: Weapon.AttackTypeEnum, weapon: Weapon, animationSpeed : float = 1.0) -> void:
	var anim := "%s_%s" % [weapon.weaponName.to_lower(), Weapon.AttackTypeEnum.keys()[attack_type].to_lower()]

	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim, -1, animationSpeed)
	else:
		# fallback to generic
		match attack_type:
			Weapon.AttackTypeEnum.LIGHTATTACK: play_lightHit_animation(animationSpeed)
			Weapon.AttackTypeEnum.HEAVYATTACK: play_heavyHit_animation(animationSpeed)
			Weapon.AttackTypeEnum.SPECIALATTACK: play_specialHit_animation(animationSpeed)

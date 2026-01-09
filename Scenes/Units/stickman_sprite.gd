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

var idle_animations = ["idle"]
var fighting_animations = ["stance"]
var dodge_animations = ["dodge1","dodge2"]
var cast_animations = []
@export var attack_animations := {
	Weapon.AttackTypeEnum.LIGHTATTACK: ["lightattack1", "lightattack2"],
	Weapon.AttackTypeEnum.HEAVYATTACK: ["heavyattack1", "heavyattack2"],
}
var light_combo_index : int = 0
var heavy_combo_index : int = 0
var special_combo_index : int = 0

func _ready() -> void:
	selfmodulate()

func selfmodulate() -> void : 
	$BodySprite.self_modulate = bodyColor

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
	else : 
		var anim = idle_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_fighting_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if fighting_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = fighting_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_walk_animation(animationSpeed : float = 1.0):
	if animationSpeed != 1.0 :
		$AnimationPlayer.play("walk", -1, animationSpeed) 
	else : 
		$AnimationPlayer.play("walk", -1, randf_range(0.75,1.25))

func play_dodge_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if dodge_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = dodge_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_cast_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if cast_animations.is_empty() :
		printerr("No cast animation !")
		return
	if cast_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = cast_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_lightHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK][light_combo_index]
		$AnimationPlayer.play(anim, -1, animationSpeed)
	light_combo_index = (light_combo_index + 1) % attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK].size()

func play_heavyHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.HEAVYATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = attack_animations[Weapon.AttackTypeEnum.HEAVYATTACK].pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_attack_animation(attack_type: Weapon.AttackTypeEnum, weapon: Weapon) -> void:
	var attack_name : String = Weapon.AttackTypeEnum.keys()[attack_type].to_lower()
	var anim : String = "%s" % [attack_name]
	#print("Searching animation player for " + str(anim))
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim, -1, weapon.current_attack_speed)
	else:
		# fallback to generic
		match attack_type:
			Weapon.AttackTypeEnum.LIGHTATTACK: play_lightHit_animation(weapon.current_attack_speed)
			Weapon.AttackTypeEnum.HEAVYATTACK: play_heavyHit_animation(weapon.current_attack_speed)

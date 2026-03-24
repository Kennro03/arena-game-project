extends Node2D
class_name BaseUnitSpriteModule

var flip : bool = false

@onready var bodySprite : Sprite2D = $BodySprite
@export var bodyColor : Color = Color("White")
@export var animation_library_name: String = "Stickman"

var idle_animations = ["idle"]
var fighting_animations = ["stance"]
var dodge_animations = ["dodge1","dodge2"]
var cast_animations = ["casting"]
var stun_animations = ["stunned"]
var block_animations = ["block"]
var parry_animations = ["parry"]
@export var attack_animations := {
	Weapon.AttackTypeEnum.LIGHTATTACK: ["lightattack1", "lightattack2"],
	Weapon.AttackTypeEnum.HEAVYATTACK: ["heavyattack1", "heavyattack2"],
}
var light_combo_index : int = 0
var heavy_combo_index : int = 0
var special_combo_index : int = 0

@onready var prefix : String = animation_library_name + "/"

func _ready() -> void:
	bodyColor = owner.sprite_color
	selfmodulate()

func update_spritesheet() -> void:
	var type = owner.weapon.weaponType if owner.weapon else 0
	if owner.weapon_spritesheets.has(type):
		$BodySprite.texture = owner.weapon_spritesheets[type]
	else:
		$BodySprite.texture = owner.weapon_spritesheets[Weapon.WeaponTypeEnum.UNARMED]

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
		var anim = prefix + idle_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_fighting_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if fighting_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + fighting_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_walk_animation(animationSpeed : float = 1.0):
	var anim = prefix + "walk"
	if animationSpeed != 1.0 :
		$AnimationPlayer.play(anim, -1, animationSpeed) 
	else : 
		$AnimationPlayer.play(anim, -1, randf_range(0.75,1.25))

func play_dodge_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if dodge_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + dodge_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_stun_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if stun_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + stun_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_cast_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if cast_animations.is_empty() :
		printerr("No cast animation !")
		return
	if cast_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + cast_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_lightHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK][light_combo_index]
		$AnimationPlayer.play(anim, -1, animationSpeed)
	light_combo_index = (light_combo_index + 1) % attack_animations[Weapon.AttackTypeEnum.LIGHTATTACK].size()

func play_heavyHit_animation(animationSpeed : float = 1.0, animationName : String = "") -> void : 
	if attack_animations[Weapon.AttackTypeEnum.HEAVYATTACK].has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + attack_animations[Weapon.AttackTypeEnum.HEAVYATTACK].pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_attack_animation(attack_type: Weapon.AttackTypeEnum, weapon: Weapon) -> void:
	var attack_name : String = Weapon.AttackTypeEnum.keys()[attack_type].to_lower()
	var anim : String = prefix + "%s" % [attack_name]
	#print("Searching animation player for " + str(anim))
	if $AnimationPlayer.has_animation(anim):
		$AnimationPlayer.play(anim, -1, weapon.current_attack_speed)
	else:
		# fallback to generic
		match attack_type:
			Weapon.AttackTypeEnum.LIGHTATTACK: play_lightHit_animation(weapon.current_attack_speed)
			Weapon.AttackTypeEnum.HEAVYATTACK: play_heavyHit_animation(weapon.current_attack_speed)

func play_block_animation(animationSpeed : float = 1.0, animationName : String = "") -> void:
	if block_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + block_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

func play_parry_animation(animationSpeed : float = 1.0, animationName : String = "") -> void:
	if parry_animations.has(animationName) :
		$AnimationPlayer.play(animationName, -1, animationSpeed)
	else : 
		var anim = prefix + parry_animations.pick_random()
		$AnimationPlayer.play(anim, -1, animationSpeed)

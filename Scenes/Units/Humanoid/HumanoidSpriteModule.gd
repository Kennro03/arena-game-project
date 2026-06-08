extends SpriteModule
class_name HumanoidSpriteModule

@onready var head: Node2D = $Head
@onready var skull: Sprite2D = $Head/Skull
@onready var eyes: Sprite2D = $Head/Eyes

@onready var body: Node2D = $Body
@onready var torso: Sprite2D = $Body/Torso

@onready var hand_right: Sprite2D = $HandRight
@onready var hand_left: Sprite2D = $HandLeft

@onready var leg_right: Sprite2D = $LegRight
@onready var leg_left: Sprite2D = $LegLeft

@onready var weapon_handle: Node2D = %WeaponHandle
@onready var weapon_sprite_2d: Sprite2D = %WeaponSprite2D

# each limb can have its texture swapped independently
@export var head_texture: Texture2D
@export var eyes_texture: Texture2D
@export var torso_texture: Texture2D
@export var hands_texture: Texture2D
@export var feet_texture: Texture2D

func _ready() -> void:
	update_sprites()

func update_sprites() -> void: # called when sprites/armor/weapon change
	var unit := owner as Humanoid
	skull.texture = head_texture
	eyes.texture = eyes_texture
	torso.texture = torso_texture
	hand_right.texture = hands_texture
	hand_left.texture = hands_texture
	leg_right.texture = feet_texture
	leg_left.texture = feet_texture
	#weapon.texture = weapon_texture or something
	head.modulate = unit.sprite_color
	body.modulate = unit.sprite_color
	hand_right.modulate = unit.sprite_color
	hand_left.modulate = unit.sprite_color
	leg_right.modulate = unit.sprite_color
	leg_left.modulate = unit.sprite_color
	

func play_idle() -> void: 
	animation_player.play("Stickman/idle", -1, randf_range(0.5,1.10))

func play_move() -> void: 
	var unit := owner as Humanoid
	if unit.stats.current_movement_speed >= 30.0 :
		animation_player.play("Stickman/run",-1,2.0)
	else : 
		animation_player.play("Stickman/walk")

func play_attack(_attack_type: Weapon.AttackTypeEnum, _weapon: Weapon) -> void: 
	match _weapon.weaponType :
		Weapon.WeaponTypeEnum.UNARMED :
			if _attack_type == Weapon.AttackTypeEnum.LIGHTATTACK :
				animation_player.play("Stickman/unarmed_lightattack_1")
			elif _attack_type == Weapon.AttackTypeEnum.HEAVYATTACK :
				animation_player.play("Stickman/unarmed_heavyattack_1")
		_:
			if _attack_type == Weapon.AttackTypeEnum.LIGHTATTACK :
				animation_player.play("Stickman/unarmed_lightattack_1")
			elif _attack_type == Weapon.AttackTypeEnum.HEAVYATTACK :
				animation_player.play("Stickman/unarmed_heavyattack_1")

func play_hurt() -> void:
	animation_player.play("Stickman/hurt")

func play_death() -> void: 
	# implement basic death position animation
	animation_player.play("BaseUnit/go_down")

func play_block() -> void: 
	animation_player.play("Stickman/block")

func play_parry() -> void: 
	animation_player.play("Stickman/parry")

func play_dodge() -> void:
	animation_player.play("Stickman/dodge_1")

func play_instant_cast() -> void: pass 

func play_channel_cast() -> void: pass 

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

# each limb can have its texture swapped independently
@export var head_texture: Texture2D
@export var eyes_texture: Texture2D
@export var torso_texture: Texture2D
@export var hands_texture: Texture2D
@export var feet_texture: Texture2D

func _ready() -> void:
	update_sprites()

func update_sprites() -> void: # called when sprites/armor/weapon change
	skull.texture = head_texture
	eyes.texture = eyes_texture
	torso.texture = torso_texture
	hand_right.texture = hands_texture
	hand_left.texture = hands_texture
	leg_right.texture = feet_texture
	leg_left.texture = feet_texture
	#weapon.texture = weapon_texture or something

func play_idle() -> void: 
	animation_player.play("Stickman/idle", -1, randf_range(0.5,1.10))

func play_move(_direction: Vector2) -> void: 
	animation_player.play("walk")
	if _direction.x != 0:
		scale.x = sign(_direction.x) # flip based on direction

func play_attack(_attack_type: Weapon.AttackTypeEnum, _weapon: Weapon) -> void: pass

func play_hurt() -> void: pass

func play_death() -> void: pass

func play_block() -> void: pass

func play_parry() -> void: pass

func play_dodge() -> void: pass

func play_instant_cast() -> void: pass 

func play_channel_cast() -> void: pass 

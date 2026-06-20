extends SpriteModule
class_name HumanoidSpriteModule

const PALETTE_SWAP_MATERIAL = preload("uid://dq56kvtjp86e0")

@onready var humanoid: Humanoid = $".."

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
@onready var weapon_sprite: Sprite2D = %WeaponSprite2D

# each limb can have its texture swapped independently
@export var head_texture: Texture2D
@export var eyes_texture: Texture2D
@export var torso_texture: Texture2D
@export var hands_texture: Texture2D
@export var feet_texture: Texture2D

func _ready() -> void:
	pass

func update_sprites() -> void: # called when sprites/armor/weapon change
	print("Updating sprites.")
	var unit := owner as Humanoid
	
	skull.texture = head_texture
	eyes.texture = eyes_texture
	torso.texture = torso_texture
	hand_right.texture = hands_texture
	hand_left.texture = hands_texture
	leg_right.texture = feet_texture
	leg_left.texture = feet_texture
	
	head.modulate = unit.sprite_color
	body.modulate = unit.sprite_color
	hand_right.modulate = unit.sprite_color
	hand_left.modulate = unit.sprite_color
	leg_right.modulate = unit.sprite_color
	leg_left.modulate = unit.sprite_color
	
	update_weapon_visuals.call_deferred(humanoid.weapon)
	reset_sprite()

func reset_draw_order() -> void:
	set_draw_order("HandLeft",0)
	set_draw_order("LegLeft",1)
	set_draw_order("Body",2)
	set_draw_order("Head",3)
	set_draw_order("WeaponHandle",4)
	set_draw_order("HandRight",5)
	set_draw_order("LegRight",6)

func play_idle() -> void: 
	reset_sprite()
	animation_player.play("Stickman/idle", -1, randf_range(0.5,1.10))

func play_move() -> void: 
	reset_sprite()
	var unit := owner as Humanoid
	
	var wep_type : String = str(Weapon.WeaponTypeEnum.keys()[unit.weapon.weaponType]).to_lower()
	var category : String = str(Weapon.WeaponCategoryEnum.keys()[unit.weapon.weaponCategory]).to_lower()
	
	var candidates : Array[String ]= [
		"Stickman/run_%s" % [wep_type],    # ex. greatSword_run
		"Stickman/run_%s" % [category],    # ex. heavy_run
		"Stickman/run_default",                    # run (final fallback)
	]
	
	play_candidates(candidates, 2.0)

func play_attack() -> void: 
	reset_sprite()
	var _weapon := humanoid.weapon
	
	# check and play exclusive animation in priority
	var exclusive_animations_arr : Array[String] = _weapon.exclusive_animations
	if exclusive_animations_arr != [] :
		var picked_exclusive_animation : String = exclusive_animations_arr.pick_random()
		if exclusive_animations_arr != [] and animation_player.has_animation(picked_exclusive_animation):
			animation_player.play(picked_exclusive_animation)
			return
	
	var wep_type : String = str(Weapon.WeaponTypeEnum.keys()[_weapon.weaponType]).to_lower()
	var category : String = str(Weapon.WeaponCategoryEnum.keys()[_weapon.weaponCategory]).to_lower()
	var selected_attack_anim : String = "" 
	if _weapon and _weapon.allowed_animations != []  : 
		selected_attack_anim = str(_weapon.allowed_animations.pick_random())
	
	var candidates : Array[String ]= [
		"Stickman/%s_%s" % [wep_type,selected_attack_anim],   # ex. sword_slash
		"Stickman/%s_%s" % [category,selected_attack_anim],  # ex. medium_slash
		"Stickman/default_%s" % selected_attack_anim,               # ex. default_slash
		"Stickman/unarmed_punch",                    # unarmed_punch (final fallback)
	]
	play_candidates(candidates)

func play_hurt() -> void:
	animation_player.play("Stickman/hurt")
	reset_sprite()

func play_death() -> void: 
	# implement basic death position animation
	reset_sprite()
	animation_player.play("BaseUnit/go_down")

func play_block() -> void: 
	reset_sprite()
	animation_player.play("Stickman/block")

func play_parry() -> void: 
	reset_sprite()
	animation_player.play("Stickman/parry")

func play_dodge() -> void:
	reset_sprite()
	var prefix := "Stickman/dodge_1"
	var anim := get_random_animation(prefix)
	animation_player.play(anim)

func play_instant_cast() -> void: pass 

func play_channel_cast() -> void: pass 

func update_weapon_visuals(weapon: Weapon) -> void:
	if weapon == null or weapon.weaponType == Weapon.WeaponTypeEnum.UNARMED:
		weapon_sprite.visible = false
		return
	
	# gauntlets special case
	if weapon.weaponType == Weapon.WeaponTypeEnum.GAUNTLET :
		hand_right.texture = weapon.weaponSprite
		hand_left.texture = weapon.weaponSprite
		weapon_sprite.texture = null
		weapon_sprite.visible = false
		weapon_sprite.offset = Vector2.ZERO
		return
	
	weapon_sprite.texture = weapon.weaponSprite
	weapon_sprite.visible = true
	
	weapon_sprite.material = PALETTE_SWAP_MATERIAL.duplicate(true)
	
	if weapon.weapon_material and weapon.weapon_material.material_color_palette != null:
		weapon_sprite.material.set_shader_parameter("original_palette", preload("uid://dv8kdjtdqrghu") )
		weapon_sprite.material.set_shader_parameter("new_palette", weapon.weapon_material.material_color_palette)
		weapon_sprite.material.set_shader_parameter("colors_count", 5)
	else:
		printerr("Weapon %s has no weaponColorPalette" % weapon.item_name)
		weapon_sprite.material.set_shader_parameter("original_palette", preload("uid://dv8kdjtdqrghu") )
		weapon_sprite.material.set_shader_parameter("new_palette", preload("uid://dv8kdjtdqrghu"))
		weapon_sprite.material.set_shader_parameter("colors_count", 5)

	# offset so grip sits at handle origin
	# adjust per weapon type based on your spritesheet layout
	match weapon.weaponType:
		Weapon.WeaponTypeEnum.DAGGER:
			weapon_sprite.offset = Vector2(5, 0)
		Weapon.WeaponTypeEnum.WAND:
			weapon_sprite.offset = Vector2(5, 0)
		Weapon.WeaponTypeEnum.SWORD:
			weapon_sprite.offset = Vector2(11, 0)
		Weapon.WeaponTypeEnum.SPEAR:
			weapon_sprite.offset = Vector2(2, 0)
		Weapon.WeaponTypeEnum.FOCI_STAFF:
			weapon_sprite.offset = Vector2(7, 0)
		Weapon.WeaponTypeEnum.HAMMER:
			weapon_sprite.offset = Vector2(10, 0)
		Weapon.WeaponTypeEnum.GREATSWORD:
			weapon_sprite.offset = Vector2(16, 0)
		_:
			weapon_sprite.offset = Vector2.ZERO

func reset_sprite()-> void :
	animation_player.play("Stickman/RESET")

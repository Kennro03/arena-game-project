extends Node2D
class_name AttackVisual

@onready var sprite: AnimatedSprite2D = %Sprite

enum ScaleMode {
	NONE,           # use sprite as-is
	FIT_TO_SIZE,    # stretch to match hitbox size
	UNIFORM,        # scale uniformly by size.x
}

@export var scale_mode: ScaleMode = ScaleMode.FIT_TO_SIZE
@export var lifetime: float = -1.0      # -1 = play once and auto-free
@export var z_offset: int = 0

var _elapsed: float = 0.0

func setup(
		frames: SpriteFrames,
		size: Vector2,
		shape: HitboxData.Shape,
		angle: float = 0.0,
		animation: String = "default",
		color_mod: Color = Color.WHITE) -> void:
	
	sprite.sprite_frames = frames
	sprite.modulate = color_mod
	rotation = angle
	z_index = z_offset
	
	_apply_scale(size, shape, frames, animation)
	sprite.play(animation)
	
	if lifetime < 0:
		# auto-free when animation finishes
		sprite.animation_finished.connect(queue_free)

func _apply_scale(size: Vector2, shape: HitboxData.Shape, frames: SpriteFrames, animation: String) -> void:
	if scale_mode == ScaleMode.NONE or frames.get_frame_count(animation) == 0:
		return
	
	var tex := frames.get_frame_texture(animation, 0)
	if tex == null:
		return
	var frame_size := Vector2(tex.get_width(), tex.get_height())
	
	match scale_mode:
		ScaleMode.FIT_TO_SIZE:
			match shape:
				HitboxData.Shape.CIRCLE:
					var diameter := size.x * 2.0
					sprite.scale = Vector2(diameter, diameter) / frame_size
				HitboxData.Shape.RECTANGLE :
					sprite.scale = size / frame_size
				HitboxData.Shape.CONE :
					sprite.scale = size / frame_size
					global_position.x += size.x/2
		ScaleMode.UNIFORM:
			var s := size.x / frame_size.x
			sprite.scale = Vector2(s, s)

func _process(delta: float) -> void:
	if lifetime > 0:
		_elapsed += delta
		if _elapsed >= lifetime:
			queue_free()

static func spawn(
		parent: Node,
		_position: Vector2,
		frames: SpriteFrames,
		size: Vector2,
		shape: HitboxData.Shape,
		angle: float = 0.0,
		animation: String = "default",
		_lifetime: float = -1.0,
		_modulate: Color = Color.WHITE) -> AttackVisual:
	const SCENE : PackedScene = preload("res://Scenes/Hitboxes/attack_visual.tscn")
	var visual : AttackVisual = SCENE.instantiate()
	visual.lifetime = _lifetime
	parent.add_child(visual)
	visual.global_position = _position
	visual.setup(frames, size, shape, angle, animation, _modulate)
	return visual

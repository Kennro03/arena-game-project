extends SkillEffect
class_name HitboxEffect

@export var hitbox_scene: PackedScene = preload("res://Scenes/Hitboxes/Hitbox.tscn")
#default values, used if not provided in the context
@export var caster_offset: Vector2 = Vector2(40, 0)
@export var shape: Shape2D = CapsuleShape2D.new()
@export var duration: float = 0.2
@export var nested_effects: Array[SkillEffect] = []
@export var rotation_offset: float = 0.0
var hitbox = hitbox_scene.instantiate()


func apply(caster: Node2D, _context: Dictionary = {}):
	var target_point = _context.get("target_point", Vector2.ZERO)
	
	#context override
	hitbox.caster = caster
	hitbox.shape = _context.get("shape", shape)
	hitbox.duration = _context.get("duration", duration)
	hitbox.nested_effects = _context.get("nested_effects", nested_effects)
	hitbox.rotation = _context.get("rotation_offset", rotation_offset)
	#targets = _context.get("targets", targets)
	
	# Hitbox and orientation placement
	var spawn_pos = caster.global_position + caster_offset.rotated(caster.rotation)
	var spawn_rot = caster.rotation + rotation_offset
	hitbox.set_origin(spawn_pos, spawn_rot)
	
	caster.get_parent().add_child(hitbox)


func get_targets() -> Array[Node2D]:
	return hitbox.target_list

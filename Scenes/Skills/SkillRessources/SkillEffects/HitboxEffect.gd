extends SkillEffect
class_name HitboxEffect

@export var hitbox_scene: PackedScene = preload("res://Scenes/Hitboxes/Hitbox.tscn")
#default values, used if not provided in the context
@export var caster_offset: Vector2 = Vector2(0, 0)
@export var shape: Shape2D = CapsuleShape2D.new()
@export var duration: float = 0.2
@export var nested_effects: Array[SkillEffect] = [] #extra effects such as another hitbox ? Not implemented
@export var rotation_offset: float = 0.0
var hitbox : Node


func apply(_caster: Node2D, _context: Dictionary = {}):
	hitbox = hitbox_scene.instantiate()
	var _target_point = _context.get("target_point", Vector2.ZERO)
	
	#context override
	hitbox.caster = _context.get("caster", _caster)
	hitbox.shape = _context.get("shape", shape)
	hitbox.duration = _context.get("duration", duration)
	#hitbox.nested_effects = _context.get("nested_effects", nested_effects)
	hitbox.rotation = _context.get("rotation_offset", rotation_offset)
	#targets = _context.get("targets", targets)
	hitbox.follow_target = _caster.get_path()
	#hitbox.follow_offset = Vector2(0.0,0.0)
	
	caster_offset = _context.get("caster_offset", caster_offset)
	
	# Hitbox and orientation placement
	var spawn_pos = _caster.global_position + caster_offset
	var spawn_rot = _caster.rotation + rotation_offset
	hitbox.set_origin(spawn_pos, spawn_rot)
	
	_caster.get_parent().add_child(hitbox)


func get_targets() -> Array[Node2D]:
	return hitbox.target_list

extends SkillEffect
class_name ProjectileEffect

var hitbox_scene: PackedScene = preload("res://Scenes/Hitboxes/Hitbox.tscn")

@export var shape: Shape2D = RectangleShape2D.new()
@export var rotation_offset: float = 0.0
#default values, used if not provided in the context
@export var caster_offset: Vector2 = Vector2(0, 0)
@export var duration: float = 5.0
@export var nested_effects: Array[SkillEffect] = [] #extra effects such as another hitbox ? Not implemented
@export var projectile_speed: float = 400.0
var hitbox : Node

func apply(_caster: Node2D, _context: Dictionary = {}):
	hitbox = hitbox_scene.instantiate()
	#context override
	hitbox.caster = _context.get("caster", _caster)
	hitbox.shape = _context.get("shape", shape)
	hitbox.duration = _context.get("duration", duration)
	#hitbox.nested_effects = _context.get("nested_effects", nested_effects)
	
	# Hitbox and orientation placement
	var _target_point = _context.get("target_point", _caster.global_position)
	var direction: Vector2 = (_target_point.position - _caster.position).normalized()
	var angle_to_target: float = direction.angle()
	hitbox.rotation = angle_to_target 
	var forward_offset = direction * caster_offset.x
	var side_offset = Vector2(-direction.y, direction.x) * caster_offset.y
	var spawn_pos = _caster.global_position + forward_offset + side_offset
	var spawn_rot = angle_to_target + deg_to_rad(rotation_offset)
	hitbox.set_origin(spawn_pos, spawn_rot)
	
	hitbox.move_over_time = true
	hitbox.velocity = direction * projectile_speed
	
	_caster.get_parent().add_child(hitbox)


func get_targets() -> Array[Node2D]:
	if hitbox :
		return hitbox.target_list
	else : 
		printerr("no hitbox")
		return []

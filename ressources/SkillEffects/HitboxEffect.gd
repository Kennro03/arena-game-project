extends SkillEffect
class_name HitboxEffect

signal hitboxskilleffect_finished(SkillEffect)

var hitbox_scene: PackedScene = preload("res://Scenes/Hitboxes/Hitbox.tscn")

#default values, used if not provided in the context
@export var shape: Shape2D = CapsuleShape2D.new()
@export var duration: float = 0.75
@export var caster_offset: Vector2 = Vector2(0, 0)
@export var rot_offset: float = 0.0
@export var follow_caster: bool = true
@export var velocity: float = 0.0
#@export var nested_effects: Array[SkillEffect] = [] #extra effects such as another hitbox ? Not implemented

var time_elapsed : float = 0.0
var hitbox : Node
var hit_targets: Array[Node2D] = []

func apply(_caster: Node2D, _context: Dictionary = {}):
	hitbox = hitbox_scene.instantiate()
	
	#context override
	hitbox.caster = _context.get("caster", _caster)
	hitbox.shape = _context.get("hitbox_shape", shape)
	hitbox.duration = _context.get("hitbox_duration", duration)
	velocity = _context.get("hitbox_velocity",velocity)
	
	# Hitbox and orientation placement
	var _target_point = _context.get("target_point", _caster.global_position)
	var direction: Vector2 = (_target_point.position - _caster.position).normalized()
	var angle_to_target: float = direction.angle()
	hitbox.rotation = angle_to_target 
	var forward_offset = direction * caster_offset.x
	var side_offset = Vector2(-direction.y, direction.x) * caster_offset.y
	var spawn_pos = _caster.global_position + forward_offset + side_offset
	var spawn_rot = angle_to_target + deg_to_rad(rot_offset)
	hitbox.set_origin(spawn_pos, spawn_rot)
	
	#Movement conditionals
	if follow_caster == true :
		hitbox.follow_target = _caster.get_path()
		hitbox.follow_offset = forward_offset + side_offset
	if velocity >= 0.01 :
		hitbox.move_over_time = true
		hitbox.velocity = direction * velocity
	
	#assign hitbox to scene
	_caster.get_parent().add_child(hitbox)


func _process(delta):
	time_elapsed += delta
	if time_elapsed >= duration:
		time_elapsed = 0.0
		emit_signal("hitboxskilleffect_finished", self)

func get_targets() -> Array[Node2D]:
	if hitbox :
		return hitbox.target_list
	else : 
		#print("no hitbox")
		return []

func _on_hitbox_end():
	print("SkillEffect " + str(self) + " finished.")
	emit_signal("hitboxskilleffect_finished", self)
	pass

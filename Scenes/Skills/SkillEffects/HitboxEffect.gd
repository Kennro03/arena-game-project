extends SkillEffect
class_name HitboxEffect

@export var hitbox_scene: PackedScene = preload("res://Scenes/Hitboxes/Hitbox.tscn")
@export var shape: Shape2D = CapsuleShape2D.new()
@export var offset: Vector2 = Vector2(40, 0) # relative to caster
@export var duration: float = 0.2
@export var nested_effects: Array[SkillEffect] = []

func apply(caster: Node2D, _targets: Array[Node], _context: Dictionary = {}):
	var hitbox = hitbox_scene.instantiate()
	hitbox.global_position = caster.global_position + offset.rotated(caster.rotation)
	hitbox.set("shape", shape)
	hitbox.set("caster", caster) # pass reference to the hitbox
	hitbox.set("duration", duration)
	hitbox.set("effects", nested_effects)
	caster.get_parent().add_child(hitbox)

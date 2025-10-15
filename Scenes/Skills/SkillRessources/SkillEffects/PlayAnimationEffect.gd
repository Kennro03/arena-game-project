extends SkillEffect
class_name PlayAnimationEffect

@export var animation_name : String

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	_caster.get_node("AnimationPlayer").play(_context.get("animation"))

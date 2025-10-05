extends SkillEffect
class_name KnockBackEffect

@export var power: float = 300.0
@export var direction : Vector2

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	direction = _context.get("direction", direction)
	print("knockback direction : " + str(direction))
	#_context.get("direction", Vector2.ZERO)
	for t in _context.get("targets"):
		if t.has_method("apply_knockback") and direction:
			t.apply_knockback(t,direction,power)

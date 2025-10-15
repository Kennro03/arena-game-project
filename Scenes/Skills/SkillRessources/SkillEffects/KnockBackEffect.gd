extends SkillEffect
class_name KnockBackEffect

@export var power: float = 300.0
@export var direction : Vector2

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	
	#print("knockback direction : " + str(direction))
	#_context.get("direction", Vector2.ZERO)
	for t in _context.get("targets"):
		direction = t.position - _caster.position
		if t.has_method("apply_knockback") and direction:
			t.apply_knockback(t,direction,power)

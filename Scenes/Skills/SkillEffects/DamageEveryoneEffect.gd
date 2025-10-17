extends SkillEffect
class_name DamageEveryoneEffect

@export var amount: float = 10.0

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	for t in _context.get("targets"):
		if t.has_method("take_damage"):
			t.take_damage(amount)

extends SkillEffect
class_name DamageOthersEffect

@export var amount: float = 10.0

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	for t in _context.get("targets"):
		if t != _caster :
			if t.has_method("take_damage"):
				t.take_damage(amount)

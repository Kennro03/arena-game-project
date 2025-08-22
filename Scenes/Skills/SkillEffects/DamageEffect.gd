extends SkillEffect
class_name DamageEffect

@export var amount: float = 10.0

func apply(caster: Node2D, targets: Array[Node], context: Dictionary = {}) -> void:
	for t in targets:
		if t.has_method("take_damage"):
			t.take_damage(amount)

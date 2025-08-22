extends SkillEffect
class_name KnockBackEffect

@export var power: float = 300.0

func apply(caster: Node2D, targets: Array[Node], context: Dictionary = {}) -> void:
	var direction: Vector2 = context.get("direction", Vector2.ZERO)
	for t in targets:
		if t.has_method("apply_knockback"):
			t.apply_knockback(t,direction,power)

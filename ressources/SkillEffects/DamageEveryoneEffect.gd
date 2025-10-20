extends SkillEffect
class_name DamageEveryoneEffect

@export var amount: float = 10.0

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	for t in _context.get("targets"):
		if t.has_method("take_damage"):
			t.take_damage(amount)

func modify_hit(_caster: Node2D, _hit_result: HitData, _context: Dictionary = {}) -> HitData:
	var hit_result : HitData = _hit_result
	hit_result.damage += amount
	return hit_result

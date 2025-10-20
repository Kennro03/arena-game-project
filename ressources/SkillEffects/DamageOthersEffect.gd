extends SkillEffect
class_name DamageOthersEffect

@export var amount: float = 10.0

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	for t in _context.get("targets"):
		if t != _caster :
			if t.has_method("take_damage"):
				t.take_damage(amount)

func modify_hit(_caster: Node2D, _hit_result: HitData, _context: Dictionary = {}) -> HitData:
	if _hit_result == null:
		printerr("modify_hit() received null hit_result, creating new one.")
		_hit_result = HitData.new()
	for t in _context.get("targets"):
		if t != _caster :
			_hit_result.damage += amount
	return _hit_result

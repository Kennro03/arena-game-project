extends ApplyEffect
class_name DamageEffect

@export var amount: float = 10.0

func modify_hit(_caster: Node2D, _hit_result: HitData, _context: Dictionary = {}) -> HitData:
	if _hit_result == null:
		printerr("modify_hit() received null hit_result, creating new one.")
		_hit_result = HitData.new()
	_hit_result.damage += amount
	return _hit_result

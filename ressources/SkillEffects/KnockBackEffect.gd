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

func modify_hit(_caster: Node2D, _hit_result: HitData, _context: Dictionary = {}) -> HitData:
	if _hit_result == null:
		printerr("modify_hit() received null hit_result, creating new one.")
		_hit_result = HitData.new()
	for t in _context.get("targets"):
		if t != _caster :
			direction = t.position - _caster.position
			_hit_result.knockback_force += power
			_hit_result.knockback_direction = direction
	return _hit_result

extends SkillEffect
class_name SkillEffect_GainShield

@export var amount: float = 10.0

func _apply_to(_target: BaseUnit, _caster: BaseUnit, _context: Dictionary) -> void:
	_target.stats.shield += amount

extends SkillEffect
class_name Effect_HealPercent

@export var percent: float = 0.1

func _apply_to(_target: BaseUnit, _caster: BaseUnit, _context: Dictionary) -> void:
	_target.stats.health += _target.stats.current_max_health * percent

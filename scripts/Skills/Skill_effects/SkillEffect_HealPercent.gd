extends SkillEffect
class_name Effect_HealPercent

@export var base_percent: float = 0.1
@export var heal_scalings: Array[StatScaling] = []

func _apply_to(_target: BaseUnit, _caster: BaseUnit, _context: Dictionary) -> void:
	var total_healing_percent : float = base_percent
	
	for scaling in heal_scalings:
		total_healing_percent += scaling.compute(_caster.stats)
	
	_target.stats.health += _target.stats.current_max_health * total_healing_percent

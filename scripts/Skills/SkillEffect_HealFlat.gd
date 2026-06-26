extends SkillEffect
class_name Effect_HealFlat

@export var amount: float = 1.0
@export var heal_scalings: Array[StatScaling] = []

func _apply_to(_target: BaseUnit, _caster: BaseUnit, _context: Dictionary) -> void:
	var total_healing_amount : float = amount
	
	for scaling in heal_scalings:
		total_healing_amount += scaling.compute(_caster.stats)
	
	_target.stats.health += total_healing_amount

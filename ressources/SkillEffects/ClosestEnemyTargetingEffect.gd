extends SkillEffect

@export var number_of_targets: int = 2
@export var range: float = 0.0

func apply(_caster: Node2D, _context: Dictionary = {}) -> void:
	var targets : Array[Node2D]
	range = _context.get("activation_range",range)
	for n in number_of_targets : 
		if range == 0.0 : 
			range = INF
		_caster.get_closest_unit(range)
	pass

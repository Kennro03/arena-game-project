extends Resource
class_name SkillEffect

enum Target {
	SELF,
	TARGET,         # context["target"]
	ATTACKER,       # context["attacker"] 
	ALL_ALLIES,
	ALL_ENEMIES,
	NEAREST_ALLY,  
	NEAREST_ENEMY,
	AREA,           # context["position"] + range
}

@export var target: Target = Target.SELF

func apply(unit: BaseUnit, context: Dictionary) -> void:
	var targets := _resolve_targets(unit, context)
	for t in targets:
		_apply_to(t, unit, context)

func _resolve_targets(caster: BaseUnit, context: Dictionary) -> Array[BaseUnit]:
	match target:
		Target.SELF:
			return [caster]
		Target.TARGET:
			var t := context.get("target") as BaseUnit
			return [t] if t else []
		Target.ATTACKER:
			var attacker := context.get("attacker") as BaseUnit
			return [attacker] if attacker and is_instance_valid(attacker) else []
		Target.ALL_ALLIES:
			return caster.get_tree().get_nodes_in_group("living_units").filter(
				func(u): return caster.check_if_ally(u))
		Target.ALL_ENEMIES:
			return caster.get_tree().get_nodes_in_group("living_units").filter(
				func(u): return not caster.check_if_ally(u))
		Target.NEAREST_ENEMY:
			var enemy := caster.get_closest_unit(
				caster.get_tree().get_nodes_in_group("living_units"),
				INF,
				func(u): return not caster.check_if_ally(u))
			return [enemy] if enemy else []
		Target.AREA:
			var pos: Vector2 = context.get("position", caster.global_position)
			var _range: float = context.get("range", 100.0)
			return caster.get_tree().get_nodes_in_group("living_units").filter(
				func(u): return u.global_position.distance_to(pos) <= _range)
	return [caster]

func _apply_to(_target: BaseUnit, _caster: BaseUnit, _context: Dictionary) -> void:
	pass  # subclasses override this instead of apply()

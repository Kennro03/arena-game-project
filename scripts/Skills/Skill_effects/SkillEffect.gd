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

func apply(unit: Unit, context: Dictionary) -> void:
	var targets : Array[Unit] = _resolve_targets(unit, context)
	for t in targets:
		_apply_to(t, unit, context)

func _resolve_targets(caster: Unit, context: Dictionary) -> Array[Unit]:
	match target:
		Target.SELF:
			return [caster] as Array[Unit]
		Target.TARGET:
			var t : Unit = context.get("target")
			return [t] as Array[Unit] if t else [] as Array[Unit]
		Target.ATTACKER:
			var attacker := context.get("attacker") as Unit
			return [attacker] as Array[Unit] if attacker and is_instance_valid(attacker) else [] as Array[Unit]
		Target.ALL_ALLIES:
			return caster.get_tree().get_nodes_in_group("living_units").filter(
				func(u): return caster.check_if_ally(u)) as Array[Unit]
		Target.ALL_ENEMIES:
			return caster.get_tree().get_nodes_in_group("living_units").filter(
				func(u): return not caster.check_if_ally(u)) as Array[Unit]
		Target.NEAREST_ENEMY:
			var enemy : Unit = caster.get_closest_unit(
				caster.get_tree().get_nodes_in_group("living_units"),
				INF,
				func(u): return not caster.check_if_ally(u))
			return [enemy] as Array[Unit] if enemy else [] as Array[Unit]
		Target.AREA:
			var pos: Vector2 = context.get("position", caster.global_position)
			var _range: float = context.get("range", 100.0)
			return caster.get_tree().get_nodes_in_group("living_units").filter(
				func(u): return u.global_position.distance_to(pos) <= _range) as Array[Unit]
	return [caster] as Array[Unit]

func _apply_to(_target: Unit, _caster: Unit, _context: Dictionary) -> void:
	pass  # subclasses override this instead of apply()

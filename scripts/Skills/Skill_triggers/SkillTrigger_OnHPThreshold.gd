extends SkillTrigger
class_name SkillTrigger_OnHPThreshold

enum Direction { BELOW, ABOVE }

@export_range(0.0, 1.0, 0.01) var threshold: float = 0.5
@export var direction: Direction = Direction.BELOW

var _stored_callable: Callable
var _was_in_zone: bool = false

func connect_to_unit(unit: Unit, _callable: Callable) -> void:
	_was_in_zone = _in_zone(unit)
	_stored_callable = func(cur: float, max: float):
		var pct := cur / max if max > 0.0 else 0.0
		var now_in := pct <= threshold if direction == Direction.BELOW else pct >= threshold
		if now_in and not _was_in_zone:
			_callable.call({"unit": unit, "hp_percent": pct})
		_was_in_zone = now_in
	unit.stats.health_changed.connect(_stored_callable)

func disconnect_from_unit(unit: Unit, _old_callable: Callable) -> void:
	if unit.stats.health_changed.is_connected(_stored_callable):
		unit.stats.health_changed.disconnect(_stored_callable)

func _in_zone(unit: Unit) -> bool:
	var pct : float = unit.stats.current_health / unit.stats.max_health if unit.stats.max_health > 0.0 else 0.0
	return pct <= threshold if direction == Direction.BELOW else pct >= threshold

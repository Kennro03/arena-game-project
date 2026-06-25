extends SkillTrigger
class_name Trigger_OnHitReceived

var _stored_callable: Callable

func connect_to_unit(unit: BaseUnit, callable: Callable) -> void:
	_stored_callable = func(hit): callable.call({"hit": hit, "unit": unit})
	unit.hit_received.connect(_stored_callable)

func disconnect_from_unit(unit: BaseUnit, _old_callable: Callable) -> void:
	if unit.hit_received.is_connected(_stored_callable):
		unit.hit_received.disconnect(_stored_callable)

extends SkillTrigger
class_name SkillTrigger_OnKill

var _stored_callable: Callable
var _unit_ref: Unit

func connect_to_unit(unit: Unit, _callable: Callable) -> void:
	_unit_ref = unit
	_stored_callable = func(dead: Unit, killer: Unit):
		if killer == _unit_ref:
			_callable.call({"killed": dead})
	
	Events.unit_died.connect(_stored_callable)

func disconnect_from_unit(_unit: Unit, _old_callable: Callable) -> void:
	if Events.unit_died.is_connected(_stored_callable):
		Events.unit_died.disconnect(_stored_callable)

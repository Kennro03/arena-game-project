extends SkillTrigger
class_name Trigger_OnCombatStart

var _stored_callable : Callable

func connect_to_unit(_unit: Unit, _callable: Callable) -> void:
	_stored_callable = func(): _callable.call({})
	Events.combat_started.connect(_stored_callable)

func disconnect_from_unit(_unit: Unit, _old_callable: Callable) -> void:
	if Events.combat_started.is_connected(_stored_callable):
		Events.combat_started.disconnect(_stored_callable)

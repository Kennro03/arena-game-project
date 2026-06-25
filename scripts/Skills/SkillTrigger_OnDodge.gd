extends SkillTrigger
class_name SkillTrigger_OnDodge

var _stored_callable: Callable

func connect_to_unit(unit: BaseUnit, callable: Callable) -> void:
	_stored_callable = func(hit: HitData):
		if hit.outcome == HitData.HitOutcome.DODGE:
			callable.call({
				"hit": hit,
				"attacker": hit.hit_owner,  # unit whose attack was dodged
			})
	unit.hit_received.connect(_stored_callable)

func disconnect_from_unit(unit: BaseUnit, _old_callable: Callable) -> void:
	if unit.hit_received.is_connected(_stored_callable):
		unit.hit_received.disconnect(_stored_callable)

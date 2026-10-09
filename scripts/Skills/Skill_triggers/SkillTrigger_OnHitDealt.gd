extends SkillTrigger
class_name SkillTrigger_OnHitDealt

var _stored_callable: Callable

func connect_to_unit(unit: Unit, callable: Callable) -> void:
	_stored_callable = func(hit: HitData): callable.call({"hit": hit})
	unit.hit_dealt.connect(_stored_callable)

func disconnect_from_unit(unit: Unit, _old_callable: Callable) -> void:
	if unit.hit_dealt.is_connected(_stored_callable):
		unit.hit_dealt.disconnect(_stored_callable)

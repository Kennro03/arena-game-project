extends SkillTrigger
class_name Trigger_OnHitReceived

enum OutcomeFilter { ANY, HIT, DODGE, BLOCK, PARRY }

@export var outcome_filter: OutcomeFilter = OutcomeFilter.ANY

var _stored_callable: Callable

func connect_to_unit(unit: Unit, callable: Callable) -> void:
	_stored_callable = func(hit: HitData):
		if _matches(hit):
			callable.call({"hit": hit, "unit": unit, "attacker": hit.hit_owner})
	unit.hit_received.connect(_stored_callable)

func disconnect_from_unit(unit: Unit, _old_callable: Callable) -> void:
	if unit.hit_received.is_connected(_stored_callable):
		unit.hit_received.disconnect(_stored_callable)

func _matches(hit: HitData) -> bool:
	match outcome_filter:
		OutcomeFilter.ANY:   return true
		OutcomeFilter.HIT:   return hit.outcome == HitData.HitOutcome.HIT
		OutcomeFilter.DODGE: return hit.outcome == HitData.HitOutcome.DODGE
		OutcomeFilter.BLOCK: return hit.outcome == HitData.HitOutcome.BLOCK
		OutcomeFilter.PARRY: return hit.outcome == HitData.HitOutcome.PARRY
	return true

extends SkillTrigger
class_name Trigger_OnStatusApplied

@export var status_id: String = ""
var _stored_callable: Callable

func connect_to_unit(unit: BaseUnit, callable: Callable) -> void:
	_stored_callable = func(effect: StatusEffect):
		if effect.status_ID == status_id:
			callable.call({"applied_effect": effect})
	unit.statusEffectModule.connect("effect_applied_with_id", _stored_callable)

func disconnect_from_unit(unit: BaseUnit, callable: Callable) -> void:
	if unit.statusEffectModule.is_connected("effect_applied_with_id", callable):
		unit.statusEffectModule.disconnect("effect_applied_with_id", callable)

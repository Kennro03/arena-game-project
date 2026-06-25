extends SkillTrigger
class_name Trigger_OnCombatStart

var _stored_callable : Callable

func connect_to_unit(unit: BaseUnit, callable: Callable) -> void:
	var battle_manager : BattleManager = unit.get_tree().get_nodes_in_group("BattleManager")[0]
	_stored_callable = func(hit): callable.call({"hit": hit, "unit": unit})
	battle_manager.BeginEncounter.connect(_stored_callable)

func disconnect_from_unit(unit: BaseUnit, _old_callable: Callable) -> void:
	var battle_manager : BattleManager = unit.get_tree().get_nodes_in_group("BattleManager")[0]
	if battle_manager.BeginEncounter.is_connected(_stored_callable):
		battle_manager.BeginEncounter.disconnect(_stored_callable)

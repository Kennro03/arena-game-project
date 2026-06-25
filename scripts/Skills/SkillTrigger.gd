extends Resource
class_name SkillTrigger

var _callable: Callable

func connect_to_unit(unit: BaseUnit, callable: Callable) -> void:
	_callable = callable

func disconnect_from_unit(unit: BaseUnit, callable: Callable) -> void:
	pass

func tick(_delta: float) -> void:
	pass  

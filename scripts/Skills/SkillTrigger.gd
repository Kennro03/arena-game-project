extends Resource
class_name SkillTrigger

var callable: Callable

func connect_to_unit(_unit: Unit, _callable: Callable) -> void:
	callable = _callable

func disconnect_from_unit(_unit: Unit, _callable: Callable) -> void:
	pass

func tick(_delta: float) -> void:
	pass  

extends SkillTrigger
class_name SkillTrigger_Periodic

@export var interval: float = 5.0
var _elapsed: float = 0.0

var _stored_callable: Callable

func tick(_delta: float) -> void:
	_elapsed += _delta
	if _elapsed >= interval:
		_elapsed = 0.0
		_stored_callable.call({})

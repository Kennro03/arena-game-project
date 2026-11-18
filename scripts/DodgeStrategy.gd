extends Resource
class_name DodgeStrategy

## Override to perform the movement.
func execute(_unit: Unit, _trigger_data: Dictionary, _done_callback: Callable) -> void:
	_done_callback.call()

func get_animation() -> String:
	return "dodge"

## Invincibility frames during the dodge (seconds). Override per strategy.
func get_i_frames() -> float:
	return 0.0

extends Resource
class_name DodgeStrategy

## Override to perform the movement.
func execute(unit: Unit, trigger_data: Dictionary, done_callback: Callable) -> void:
	done_callback.call()

func get_animation() -> String:
	return "dodge"

## Invincibility frames during the dodge (seconds). Override per strategy.
func get_i_frames() -> float:
	return 0.0

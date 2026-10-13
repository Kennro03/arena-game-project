extends DodgeStrategy
class_name DodgeStrategy_Teleport

@export var distance: float = 96.0

func execute(unit: Unit, trigger_data: Dictionary, done_callback: Callable) -> void:
	var direction: Vector2 = trigger_data.get("direction", -Vector2.ONE)
	unit.global_position += direction.normalized() * distance
	unit.get_tree().process_frame.connect(func(): done_callback.call(), CONNECT_ONE_SHOT)

func get_animation() -> String:
	return "teleport_dodge"

func get_i_frames() -> float:
	return 0.1

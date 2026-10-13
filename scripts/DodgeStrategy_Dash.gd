extends DodgeStrategy
class_name DodgeStrategy_Dash

@export var distance_factor: float = 1.0
@export var speed_factor:    float = 1.0

func execute(unit: Unit, trigger_data: Dictionary, done_callback: Callable) -> void:
	var direction: Vector2 = trigger_data.get("direction", Vector2.RIGHT)
	var dest := unit.global_position + direction.normalized() * unit.stats.dodge_distance
	unit.movement_controller.dash_to(dest, unit.stats.dodge_speed, false)
	unit.movement_controller.job_completed.connect(
		func(): done_callback.call(), CONNECT_ONE_SHOT)  

func get_i_frames() -> float:
	return 0.2

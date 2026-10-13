extends DodgeStrategy
class_name DodgeStrategy_QuickCircle

@export var arc_degrees: float = 90.0
@export var speed: float = 300.0

func execute(unit: Unit, trigger_data: Dictionary, done_callback: Callable) -> void:
	var attacker: Unit = trigger_data.get("attacker")
	if attacker == null:
		done_callback.call()
		return
	var to_unit := unit.global_position - attacker.global_position
	var radius := to_unit.length()
	var current_angle := to_unit.angle()
	var arc := deg_to_rad(arc_degrees) * (1.0 if randf() > 0.5 else -1.0)
	var dest := attacker.global_position + Vector2(cos(current_angle + arc), sin(current_angle + arc)) * radius
	unit.movement_controller.dash_to(dest, speed, false)
	unit.movement_controller.job_completed.connect(
		func(_t): done_callback.call(), CONNECT_ONE_SHOT)

extends MovementStep
class_name MovementStep_Wait

@export var duration: float = 0.3

var _elapsed: float = 0.0

func begin(_body: CharacterBody2D, _step_start_pos: Vector2) -> void:
	_elapsed = 0.0

func tick(delta: float, body: CharacterBody2D) -> bool:
	_elapsed += delta
	body.velocity = Vector2.ZERO
	body.move_and_slide()
	return _elapsed >= duration

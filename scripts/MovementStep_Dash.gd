extends MovementStep
class_name MovementStep_Dash

## Offset from the unit's position when the step begins, in world space.
## To offset in facing direction, multiply by the unit's facing vector before passing.
@export var offset: Vector2 = Vector2(150.0, 0.0)
@export var speed: float = 400.0

var _dest: Vector2

func begin(_body: CharacterBody2D, step_start_pos: Vector2) -> void:
	_dest = step_start_pos + offset

func tick(_delta: float, body: CharacterBody2D) -> bool:
	var to_dest := _dest - body.global_position
	if to_dest.length() < 4.0:
		body.velocity = Vector2.ZERO
		body.move_and_slide()
		return true
	body.velocity = to_dest.normalized() * speed
	body.move_and_slide()
	return body.get_slide_collision_count() > 0  # also done if terrain collision

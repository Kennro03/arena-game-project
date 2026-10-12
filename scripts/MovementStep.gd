extends Resource
class_name MovementStep

## Called once when this step becomes active.
## step_start_pos is the unit's position at the moment this step began.
func begin(_body: CharacterBody2D, _step_start_pos: Vector2) -> void:
	pass

## Called each physics frame. Return true when this step is complete.
func tick(_delta: float, _body: CharacterBody2D) -> bool:
	return true

extends UnitState
class_name UnitEngaged

enum Behavior {
	STATIONARY,
	STEP_FORWARD,
	STEP_BACKWARD,
	STRAFE,
	CIRCLE,
}

const BEHAVIOR_WEIGHTS := {
	Behavior.STATIONARY:   40,
	Behavior.STEP_FORWARD: 15,
	Behavior.STEP_BACKWARD:10,
	Behavior.STRAFE:       20,
	Behavior.CIRCLE:       20,
}

const MIN_BEHAVIOR_DURATION := 0.9
const MAX_BEHAVIOR_DURATION := 3.0
const STEP_DISTANCE := 40.0

var _current_target: Unit = null
var _behavior: Behavior = Behavior.STATIONARY
var _behavior_timer: float = 0.0
var _circle_clockwise: bool = true

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.displayModule.state_rich_text_label.text = "ENGAGED"
	unit.spriteModule.play_idle()
	unit.movement_controller.job_completed.connect(_on_movement_done)
	_current_target = _find_enemy()
	_pick_new_behavior()

func exit() -> void:
	if unit.movement_controller.job_completed.is_connected(_on_movement_done):
		unit.movement_controller.job_completed.disconnect(_on_movement_done)
	unit.movement_controller.cancel()


func physics_update(delta: float) -> void:
	if unit.is_stunned:
		finished.emit(STUNNED)
		return

	_current_target = _find_enemy()

	if _current_target == null:
		unit.movement_controller.cancel()
		finished.emit(IDLE)
		return
	
	unit.face_toward(_current_target.global_position)
	
	_behavior_timer -= delta
	if _behavior_timer <= 0.0:
		_pick_new_behavior()

	# Skills take priority over weapon attacks
	#var skill_used : bool = unit.skillModule.try_use_skill(_current_target)
	#if not skill_used and
	if unit.can_hit():
		unit.attack(_current_target)
		unit.last_attack_time = 0.0
		# Change footwork after acting
		_pick_new_behavior()

	if not unit.melee_range_check(_current_target):
		finished.emit(IDLE)


func _pick_new_behavior() -> void:
	_behavior = _weighted_pick(BEHAVIOR_WEIGHTS)
	_behavior_timer = randf_range(MIN_BEHAVIOR_DURATION, MAX_BEHAVIOR_DURATION)

	# Occasionally flip circle direction on a new pick
	if _behavior == Behavior.CIRCLE or _behavior == Behavior.STRAFE:
		if randf() > 0.6:
			_circle_clockwise = not _circle_clockwise

	unit.movement_controller.cancel()
	_apply_behavior()


func _apply_behavior() -> void:
	if _current_target == null:
		return

	var to_target := _current_target.global_position - unit.global_position
	var dir_to := to_target.normalized()
	var orbit_radius := unit.weapon.current_attack_range * 0.6 if unit.weapon else 60.0
	var slow_speed := unit.stats.current_movement_speed * 0.5

	match _behavior:
		Behavior.STATIONARY:
			pass  # controller already cancelled; unit just stands

		Behavior.STEP_FORWARD:
			var dest := unit.global_position + dir_to * STEP_DISTANCE
			unit.movement_controller.navigate_to(dest, slow_speed, 10.0)

		Behavior.STEP_BACKWARD:
			var dest := unit.global_position - dir_to * STEP_DISTANCE
			unit.movement_controller.navigate_to(dest, slow_speed, 10.0)

		Behavior.STRAFE:
			var perp := Vector2(-dir_to.y, dir_to.x) * (1.0 if _circle_clockwise else -1.0)
			var dest := unit.global_position + perp * STEP_DISTANCE
			unit.movement_controller.navigate_to(dest, slow_speed * 1.1, 10.0)

		Behavior.CIRCLE:
			unit.movement_controller.start_repositioning(
				_current_target.global_position,
				orbit_radius,
				0.35,
				_circle_clockwise)


func _on_movement_done() -> void:
	# CIRCLE loops itself; everything else picks fresh behavior on arrival
	if _behavior != Behavior.CIRCLE:
		_pick_new_behavior()


func _weighted_pick(weights: Dictionary) -> Behavior:
	var total := 0
	for w: int in weights.values():
		total += w
	var roll := randi() % total
	var cumulative := 0
	for key: Behavior in weights:
		cumulative += weights[key]
		if roll < cumulative:
			return key
	return Behavior.STATIONARY

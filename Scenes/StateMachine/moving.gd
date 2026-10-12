extends UnitState
class_name UnitMoving

var _current_target: Unit = null

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.displayModule.state_rich_text_label.text = "MOVING"
	unit.spriteModule.play_move()
	_current_target = null

func physics_update(_delta: float) -> void:
	if unit.is_stunned:
		finished.emit(STUNNED)
		return

	_current_target = _find_enemy()

	if _current_target == null:
		unit.movement_controller.cancel()
		finished.emit(IDLE)
		return

	unit.face_toward(_current_target.global_position)

	# Update navigation destination every tick — target moves
	var arrive_radius := maxf(
		unit.weapon.current_attack_range * 0.60 if unit.weapon else 40.0,
		24.0)
	unit.movement_controller.navigate_to(
		_current_target.global_position,
		unit.stats.current_movement_speed,
		arrive_radius)

	if !unit.animationPlayer.is_playing():
		unit.spriteModule.play_move()

	if unit.melee_close_range_check(_current_target):
		unit.movement_controller.cancel()
		finished.emit(ENGAGED)

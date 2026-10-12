extends UnitState
class_name UnitIdle

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.displayModule.state_rich_text_label.text = "IDLE"
	unit.movement_controller.cancel()
	unit.spriteModule.play_idle()

func physics_update(_delta: float) -> void:
	if unit.is_stunned:
		finished.emit(STUNNED)
		return

	var closest_target := _find_enemy()

	if closest_target == null:
		return

	unit.face_toward(closest_target.global_position)
	
	if unit.melee_range_check(closest_target):
		finished.emit(ENGAGED)
	elif unit.stats.current_movement_speed > 0.0:
		finished.emit(MOVING)

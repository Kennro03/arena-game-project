extends BaseUnitState
class_name BaseUnitStunned

var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.spriteModule.play_stun_animation()
	unit.is_action_locked = true

func physics_update(_delta: float) -> void:
	if unit.is_stunned:
		return
	
	unit.is_action_locked = false
	finished.emit(IDLE)

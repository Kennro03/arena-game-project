extends BaseUnitState
class_name BaseUnitStunned

var remaining_stun_duration : float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.displayModule.state_rich_text_label.text = "STUNNED"
	unit.spriteModule.play_stun_animation()
	unit.is_action_locked = true
	remaining_stun_duration += _data[0]

func physics_update(_delta: float) -> void:
	if remaining_stun_duration > 0.0 :
		remaining_stun_duration -= _delta
		
		if remaining_stun_duration <= 0.0 :
			unit.is_action_locked = false
			finished.emit(IDLE)

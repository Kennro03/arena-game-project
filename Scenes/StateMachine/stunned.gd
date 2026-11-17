extends UnitState
class_name UnitStunned

var remaining_stun_duration : float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.displayModule.state_rich_text_label.text = "STUNNED"
	unit.spriteModule.play_hurt()
	remaining_stun_duration += _data.get("duration", 0.0)

func physics_update(_delta: float) -> void:
	if remaining_stun_duration > 0.0 :
		remaining_stun_duration -= _delta
		
		if remaining_stun_duration <= 0.0 :
			remaining_stun_duration = 0.0
			finished.emit(IDLE)
	else :
		finished.emit(IDLE) # entered with no duration

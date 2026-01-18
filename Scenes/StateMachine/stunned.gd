extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	owner.spriteNode.play_stun_animation()
	owner.is_action_locked = true

func physics_update(_delta: float) -> void:
	if owner.is_stunned:
		return
	
	owner.is_action_locked = false
	finished.emit(IDLE)

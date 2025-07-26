extends StickmanState
var closest_target
var closest_target_vector

func enter(previous_state_path: String, data := {}) -> void:
	%AnimationPlayer.play("walking")
	

func physics_update(_delta: float) -> void:
	closest_target = owner.get_closest_stickman(owner.aggro_range)
	closest_target_vector = owner.get_target_position_vector(closest_target.position)
	owner.position = owner.position + closest_target_vector.normalized()*owner.speed*_delta
	
	if owner.target_proximity_check(closest_target,owner.range) :
		finished.emit(IDLE)
	

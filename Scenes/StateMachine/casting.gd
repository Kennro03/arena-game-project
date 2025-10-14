extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	
	closest_target = owner.get_closest_unit(owner.aggro_range)
	if closest_target !=null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
	
	if closest_target != null and owner.target_proximity_check(closest_target,owner.attack_range) :
		finished.emit(ATTACKING)
	elif closest_target != null and !owner.target_proximity_check(closest_target,owner.attack_range):
		finished.emit(MOVING)

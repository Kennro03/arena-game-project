extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	%AnimationPlayer.stop()

func physics_update(_delta: float) -> void:
	closest_target = owner.get_closest_stickman(owner.aggro_range)
	closest_target_vector = owner.get_target_position_vector(closest_target.position)
	if closest_target_vector.x > 0 :
		%Sprite.flip_h = false
	else : 
		%Sprite.flip_h = true
	if !%AnimationPlayer.is_playing():
		%AnimationPlayer.play("walking")
	
	owner.position = owner.position + closest_target_vector.normalized()*owner.speed*_delta
	
	if owner.target_proximity_check(closest_target,owner.attack_range) :
		finished.emit(IDLE)
	

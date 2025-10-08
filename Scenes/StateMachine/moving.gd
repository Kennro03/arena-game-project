extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	%AnimationPlayer.stop()

func physics_update(_delta: float) -> void:
	closest_target = owner.get_closest_stickman(owner.aggro_range)
	if closest_target != null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
		if closest_target_vector.x > 0 :
			%Sprite.flip_h = false
		else : 
			%Sprite.flip_h = true
	else : 
		finished.emit(IDLE)
	
	if !%AnimationPlayer.is_playing():
		%AnimationPlayer.speed_scale = randf_range(0.75,1.25)
		%AnimationPlayer.play("walking")
	
	if closest_target_vector: 
		owner.position = owner.position + closest_target_vector.normalized()*owner.speed*_delta
	
	if owner.target_proximity_check(closest_target,owner.attack_range/1.5) :
		finished.emit(IDLE)

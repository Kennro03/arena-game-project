extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	%AnimationPlayer.play("fighting_stance")

func physics_update(_delta: float) -> void:
	closest_target = owner.get_closest_stickman(owner.aggro_range)
	if closest_target !=null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
	if closest_target_vector.x > 0 :
		%Sprite.flip_h = false
	else : 
		%Sprite.flip_h = true
	
	if closest_target !=null and %HitCooldown.is_stopped() :
		%AnimationPlayer.play("punch")
		owner.punch(closest_target,closest_target_vector, 650.0)
		print(str(closest_target) + " health = " + str(closest_target.health))
		%HitCooldown.start()
	
	if !closest_target :
		finished.emit(IDLE)
	if closest_target != null and !owner.target_proximity_check(closest_target,owner.attack_range):
		finished.emit(MOVING)

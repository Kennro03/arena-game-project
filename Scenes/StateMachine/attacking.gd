extends StickmanState
var closest_target
var closest_target_vector

func enter(previous_state_path: String, data := {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	closest_target = owner.get_closest_stickman(owner.aggro_range)
	if closest_target !=null and %HitCooldown.is_stopped() :
		%AnimationPlayer.play("punch")
		owner.hit(closest_target,owner.damage)
		print(str(closest_target) + " health = " + str(closest_target.health))
		%HitCooldown.start()
	
	if closest_target == null :
		finished.emit(IDLE)
	if closest_target != null and !owner.target_proximity_check(closest_target,owner.range):
		finished.emit(MOVING)

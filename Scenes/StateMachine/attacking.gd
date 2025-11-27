extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	%AnimationPlayer.play("fighting_stance")

func physics_update(_delta: float) -> void:
	if !%AnimationPlayer.is_playing():
		%AnimationPlayer.play("fighting_stance")
	
	closest_target = owner.get_closest_unit(owner.aggro_range)
	if closest_target != null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
		if closest_target_vector.x > 0 :
			%Sprite.flip_h = false
		else : 
			%Sprite.flip_h = true
	
	%SkillModule.check_skill_timepassed += _delta
	if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
		if %SkillModule.check_any_usable_skill() : 
			finished.emit(CASTING)
	
	if closest_target !=null and owner.can_hit() :
		%AnimationPlayer.play(owner.punch_animations[randi() % owner.punch_animations.size()])
		owner.punch(closest_target,owner.damage,closest_target_vector, owner.knockback)
		#print(str(closest_target) + " health = " + str(closest_target.health))
		owner.last_attack_time = 0.0
	
	
	if !closest_target :
		finished.emit(IDLE)
	if closest_target != null and !owner.target_proximity_check(closest_target,owner.attack_range):
		finished.emit(MOVING)

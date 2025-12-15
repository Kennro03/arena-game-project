extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	owner.animationPlayerNode.stop()

func physics_update(_delta: float) -> void:
	closest_target = owner.get_closest_unit()
	if closest_target != null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
		if closest_target_vector.x > 0 :
			owner.spriteNode.flipSprite(false)
		else : 
			owner.spriteNode.flipSprite(true)
	else : 
		finished.emit(IDLE)
	
	if !owner.animationPlayerNode.is_playing():
		owner.spriteNode.play_walk_animation()
	
	%SkillModule.check_skill_timepassed += _delta
	if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
		if %SkillModule.check_any_usable_skill() : 
			finished.emit(CASTING)
	
	if closest_target_vector: 
		owner.position = owner.position + closest_target_vector.normalized()*owner.stats.current_movement_speed*_delta
	
	if owner.target_proximity_check(closest_target,owner.weapon.attack_range/1.3) :
		finished.emit(IDLE)

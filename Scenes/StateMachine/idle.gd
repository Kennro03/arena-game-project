extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	if owner.is_action_locked:
		return
	if owner.is_stunned:
		finished.emit(STUNNED)
	
	if !owner.animationPlayerNode.is_playing():
		owner.spriteNode.play_idle_animation()
	
	closest_target = owner.get_closest_unit()
	
	if closest_target !=null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
	
	%SkillModule.check_skill_timepassed += _delta
	if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
		if %SkillModule.check_any_usable_skill() : 
			finished.emit(CASTING)
	
	if closest_target != null and owner.melee_range_check(closest_target) :
		finished.emit(ATTACKING)
	elif closest_target != null and !owner.melee_range_check(closest_target) and owner.stats.current_movement_speed>0.0:
		finished.emit(MOVING)

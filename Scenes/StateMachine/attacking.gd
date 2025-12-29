extends StickmanState
var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	owner.spriteNode.play_fighting_animation()

func physics_update(_delta: float) -> void:
	if owner.is_action_locked():
		return  
	if !owner.animationPlayerNode.is_playing():
		owner.spriteNode.play_fighting_animation()
	
	closest_target = owner.get_closest_unit()
	if closest_target != null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
		if closest_target_vector.x > 0 :
			owner.spriteNode.flipSprite(false)
		else : 
			owner.spriteNode.flipSprite(true)
	
	%SkillModule.check_skill_timepassed += _delta
	if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
		if %SkillModule.check_any_usable_skill() : 
			finished.emit(CASTING)
	
	if closest_target !=null and owner.can_hit() :
		owner.attack(closest_target)
		#print(str(closest_target) + " health = " + str(closest_target.health))
		owner.last_attack_time = 0.0
	
	if !closest_target :
		finished.emit(IDLE)
	if closest_target != null and !owner.target_proximity_check(closest_target,owner.weapon.attack_range):
		finished.emit(MOVING)

extends StickmanState
var closest_target
var closest_target_vector

var cast_skill = SkillRuntime
var casting_time_passed : float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	print(str(owner) + " Entered casting state.")
	owner.is_casting = false
	cast_skill = %SkillModule.get_first_usable_skill()
	casting_time_passed = 0.0
	if cast_skill : 
		if cast_skill.skill_data.cast_time > 0.0 :
			owner.is_casting = true
			#play the casting animation for the duration
		else : 
			print(cast_skill.skill_data.skill_name + " cast ended, activating.")
			owner.is_casting = false
			cast_skill.activate()
			
	else : 
		printerr("Could not retrieve a usable skill")
	pass

func physics_update(_delta: float) -> void:
	if owner.is_casting == true :
		casting_time_passed += _delta
		if casting_time_passed >= cast_skill.skill_data.cast_time:
			casting_time_passed -= cast_skill.skill_data.cast_time
			owner.is_casting = false
			print(cast_skill.skill_data.skill_name + " cast ended, activating.")
			cast_skill.activate()
			#stop cast animation
	
	closest_target = owner.get_closest_unit(owner.aggro_range)
	if closest_target !=null :
		closest_target_vector = owner.get_target_position_vector(closest_target.position)
	
	if closest_target != null and owner.target_proximity_check(closest_target,owner.attack_range) :
		finished.emit(ATTACKING)
	elif closest_target != null and !owner.target_proximity_check(closest_target,owner.attack_range):
		finished.emit(MOVING)

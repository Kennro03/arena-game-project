extends StickmanState

var closest_target
var closest_target_vector

var cast_skill = SkillRuntime
var casting_time_passed : float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	owner.is_casting = false
	cast_skill = %SkillModule.get_first_usable_skill()
	print(str(owner) + " Entered casting state. Casting " + str(cast_skill))
	
	casting_time_passed = 0.0
	if cast_skill : 
		if cast_skill.skill_data.cast_time > 0.0 :
			owner.is_casting = true
			owner.animationPlayerNode.play_cast_animation(1.0/cast_skill.skill_data.cast_time)
			#play the casting animation for the duration
		else : 
			print(cast_skill.skill_data.skill_name + " instacast, activating.")
			owner.is_casting = false
	else : 
		printerr("Could not retrieve a usable skill")
	pass

func physics_update(_delta: float) -> void:
	if cast_skill == null:
		return 
	
	
	if owner.is_casting == true :
		casting_time_passed += _delta
		if casting_time_passed >= cast_skill.skill_data.cast_time:
			casting_time_passed -= cast_skill.skill_data.cast_time
			owner.is_casting = false
			print(cast_skill.skill_data.skill_name + " cast ended after" + str(cast_skill.skill_data.cast_time) + ", activating.")
			cast_skill.activate()
			#stop cast animation
	
	if owner.is_casting == false :
		cast_skill.activate()
		print("Ended casting state")
		finished.emit(IDLE)

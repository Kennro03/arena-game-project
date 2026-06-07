extends BaseUnitState
class_name BaseUnitEngaged

var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.spriteModule.play_idle() #create 'engaged' idle animation/pose

func physics_update(_delta: float) -> void:
	if unit.is_action_locked:
		return
	if unit.is_stunned:
		finished.emit(STUNNED)
	
	if !unit.animationPlayer.is_playing():
		unit.spriteModule.play_idle()  #create 'engaged' idle animation/pose
	
	closest_target = unit.get_closest_unit(
		unit.get_units_in_group("Live_Units"),
		INF,
		func(u): return not unit.check_if_ally(u))
	
	if closest_target != null :
		closest_target_vector = unit.get_target_position_vector(closest_target.position)
		if closest_target_vector.x > 0 :
			unit.spriteModule.flipSprite(false)
		else : 
			unit.spriteModule.flipSprite(true)
	
	##Change 
	#%SkillModule.check_skill_timepassed += _delta
	#if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
	#	if %SkillModule.check_any_usable_skill() : 
	#		finished.emit(CASTING)
	
	if closest_target !=null and unit.can_hit() :
		unit.attack(closest_target)
		#print(str(closest_target) + " health = " + str(closest_target.health))
		unit.last_attack_time = 0.0
	
	if !unit.melee_range_check(closest_target):
		finished.emit(IDLE)

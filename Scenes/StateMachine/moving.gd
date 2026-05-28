extends BaseUnitState
class_name BaseUnitMoving

var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.animationPlayer.stop()

func physics_update(_delta: float) -> void:
	if unit.is_action_locked:
		return
	if unit.is_stunned:
		finished.emit(STUNNED)
	
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
	else : 
		finished.emit(IDLE)
	
	if !unit.animationPlayer.is_playing():
		unit.spriteModule.play_walk_animation()
	
	#%SkillModule.check_skill_timepassed += _delta
	#if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
	#	if %SkillModule.check_any_usable_skill() : 
	#		finished.emit(CASTING)
	
	if unit.melee_close_range_check(closest_target) :
		finished.emit(IDLE)
		return
	
	if closest_target_vector: 
		unit.position = unit.position + closest_target_vector.normalized()*unit.stats.current_movement_speed*_delta

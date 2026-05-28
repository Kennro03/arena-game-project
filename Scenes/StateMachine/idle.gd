extends BaseUnitState
class_name BaseUnitIdle

var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	if unit.is_action_locked:
		return
	if unit.is_stunned:
		finished.emit(STUNNED)
	
	if !unit.animationPlayer.is_playing():
		unit.spriteModule.play_idle_animation()
	
	closest_target = unit.get_closest_unit(
		unit.get_units_in_group("Live_Units"),
		INF,
		func(u): return not unit.check_if_ally(u))
	
	if closest_target !=null :
		closest_target_vector = unit.get_target_position_vector(closest_target.position)
	
	#%SkillModule.check_skill_timepassed += _delta
	#if %SkillModule.check_skill_timepassed >= %SkillModule.skill_check_delay : 
	#	if %SkillModule.check_any_usable_skill() : 
	#		finished.emit(CASTING)
	
	if closest_target != null and unit.melee_range_check(closest_target) :
		finished.emit(ENGAGED)
	elif closest_target != null and !unit.melee_range_check(closest_target) and owner.stats.current_movement_speed>0.0:
		finished.emit(MOVING)

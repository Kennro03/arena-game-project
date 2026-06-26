extends BaseUnitState
class_name BaseUnitCasting

var _current_skill: ActiveSkill = null

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.displayModule.state_rich_text_label.text = "CASTING"
	if _data.has("skill"):
		_current_skill = _data["skill"] as ActiveSkill
	else:
		_current_skill = unit.skillModule.get_usable_skills().front()
	
	if _current_skill == null:
		printerr("CastingState: no usable skill found")
		finished.emit(IDLE)
		return
	
	# connect to skill signals to know when we're done
	_current_skill.cast_completed.connect(_on_cast_finished, CONNECT_ONE_SHOT)
	_current_skill.cast_interrupted.connect(_on_cast_finished, CONNECT_ONE_SHOT)
	
	# tell skill module to use it
	unit.skillModule.use_skill(_current_skill)

func physics_update(_delta: float) -> void:
	# state machine blocks all other behavior while here
	# interruption is handled by ActiveSkill.try_interrupt()
	# which gets called from SkillModule.interrupt_active_skills()
	# which gets called from take_damage() / stun application
	# nothing needed here for most cases
	
	if unit.is_stunned:
		if _current_skill:
			_current_skill.try_interrupt("stun")
		# don't transition here — wait for cast_interrupted signal

func _on_cast_finished(_skill: ActiveSkill) -> void:
	_current_skill = null
	finished.emit(IDLE)

func exit() -> void:
	# clean up signal connections if we exit unexpectedly
	if _current_skill:
		if _current_skill.cast_completed.is_connected(_on_cast_finished):
			_current_skill.cast_completed.disconnect(_on_cast_finished)
		if _current_skill.cast_interrupted.is_connected(_on_cast_finished):
			_current_skill.cast_interrupted.disconnect(_on_cast_finished)
	_current_skill = null

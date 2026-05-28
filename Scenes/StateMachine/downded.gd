extends BaseUnitState
class_name BaseUnitDownded

var closest_target
var closest_target_vector

func enter(_previous_state_path: String, _data := {}) -> void:
	#owner.spriteModule.play_downded_animation()
	unit.is_action_locked = true
	unit.remove_from_group("Live_Units")
	unit.add_to_group("Downed_Units")
	unit.set_healthbar_visibility(false)
	unit.hide_shieldBar()
	unit.show_name = false

func exit() -> void:
	unit.is_action_locked = true
	unit.remove_from_group("Downed_Units")
	unit.add_to_group("Live_Units")
	unit.set_healthbar_visibility(unit.show_health)
	unit.hide_shieldBar()
	unit.show_name = true

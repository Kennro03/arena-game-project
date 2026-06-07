extends BaseUnitState
class_name BaseUnitDownded

func enter(_previous_state_path: String, _data := {}) -> void:
	owner.spriteModule.play_death()
	unit.is_action_locked = true
	unit.remove_from_group("Live_Units")
	unit.add_to_group("Downed_Units")
	unit.set_healthbar_visibility(false)
	unit.hide_shieldBar()
	unit.show_name = false
	unit.hurtbox_collision_shape.disabled = true
	unit.selection_area_collision_shape.disabled = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(unit.spriteModule, "rotation", deg_to_rad(90.0*_data["dir_mult"]), 0.75).set_trans(Tween.TRANS_QUART)

func exit() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(unit.spriteModule, "rotation", deg_to_rad(0.0), 0.75).set_trans(Tween.TRANS_QUART)
	await tween.finished
	
	owner.spriteModule.play_go_down_animation(-1.0) #play go_down animation in reverse to rise up
	unit.is_action_locked = true
	unit.remove_from_group("Downed_Units")
	unit.add_to_group("Live_Units")
	unit.set_healthbar_visibility(unit.show_health)
	unit.hide_shieldBar()
	unit.show_name = true
	unit.hurtbox_collision_shape.disabled = false
	unit.selection_area_collision_shape.disabled = false
	
	

extends UnitState
class_name UnitDownded

const FALL_DURATION := 0.75
const RISE_DURATION := 0.75

var _rotation_tween: Tween
var _reviving := false

func enter(_previous_state_path: String, _data := {}) -> void:
	_reviving = false
	unit.displayModule.state_rich_text_label.text = ""
	unit.is_downed = true
	unit.stats.vitals_locked = true                 # no damage or healing until revived
	unit.movement_controller.cancel()               # stop own movement (an active knockback still plays out)
	unit.skillModule.interrupt_active_skills("downed")
	unit.remove_from_group("Live_Units")            # no longer targeted
	unit.add_to_group("Downed_Units")
	unit.displayModule.set_healthbar_visibility(false)
	unit.displayModule.hide_shieldBar()
	unit.selection_area_collision_shape.disabled = true
	# The hurtbox stays enabled so area hits can still knock the body around (see resolve_hit).
	# Status effects keep ticking; their damage/healing is ignored while vitals are locked.
	unit.spriteModule.play_death()
	_tween_rotation(deg_to_rad(90.0 * _data.get("dir_mult", 1)), FALL_DURATION)

## Called by Unit.revive(). Restores health, plays the rise-up, then returns to Idle.
func begin_revive(health_fraction: float) -> void:
	if _reviving:
		return
	_reviving = true
	unit.stats.vitals_locked = false
	unit.stats.health = unit.stats.current_max_health * clampf(health_fraction, 0.01, 1.0)
	unit.spriteModule.play_death(-1.0)              # go_down in reverse
	_tween_rotation(0.0, RISE_DURATION)
	_rotation_tween.finished.connect(_on_rise_finished, CONNECT_ONE_SHOT)

func _on_rise_finished() -> void:
	unit.unit_revived.emit(unit)
	finished.emit(IDLE, {"revive": true})

func exit() -> void:
	# Only reached through a revive: the state machine blocks every other way out.
	if _rotation_tween:
		_rotation_tween.kill()
	unit.spriteModule.rotation = 0.0
	unit.spriteModule.modulate = Color.WHITE        # go_down greys the sprite and fades the name
	unit.displayModule.name_label.modulate = Color.WHITE
	unit.is_downed = false
	unit.stats.vitals_locked = false
	unit.remove_from_group("Downed_Units")
	unit.add_to_group("Live_Units")
	unit.displayModule.set_healthbar_visibility(unit.show_health)
	unit.displayModule.update_healthBar(unit.stats.health, unit.stats.current_max_health)
	unit.displayModule.update_shieldBar(unit.stats.shield, unit.stats.max_shield)
	unit.selection_area_collision_shape.disabled = false
	_reviving = false

func _tween_rotation(target: float, duration: float) -> void:
	if _rotation_tween:
		_rotation_tween.kill()
	_rotation_tween = create_tween()
	_rotation_tween.tween_property(unit.spriteModule, "rotation", target, duration).set_trans(Tween.TRANS_QUART)

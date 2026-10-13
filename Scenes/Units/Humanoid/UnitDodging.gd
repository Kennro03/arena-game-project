extends UnitState
class_name UnitDodging

const MAX_DODGE_DURATION : float = 1.5

var _return_state: String = IDLE
var _i_frame_timer: float = 0.0
var _timeout: float = 0.0

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	unit.displayModule.state_rich_text_label.text = "DODGING"
	_return_state = data.get("return_state", IDLE)
	_timeout = 0.0

	var strategy: DodgeStrategy = _get_strategy()
	_i_frame_timer = strategy.get_i_frames()
	unit.movement_controller.facing_locked = true
	unit.spriteModule.play_dodge()

	strategy.execute(unit as HumanoidUnit, data, _on_done)

func exit() -> void:
	unit.movement_controller.facing_locked = false

func physics_update(delta: float) -> void:
	_timeout += delta
	if _timeout >= MAX_DODGE_DURATION:
		_on_done()
		return
	if _i_frame_timer > 0.0:
		_i_frame_timer -= delta
		unit.is_dodging = true
	else:
		unit.is_dodging = false

func _on_done() -> void:
	unit.is_dodging = false
	finished.emit(_return_state)

func _get_strategy() -> DodgeStrategy:
	if unit is HumanoidUnit:
		var h := unit as HumanoidUnit
		if h.dodge_strategy != null:
			return h.dodge_strategy
	return DodgeStrategy_Dash.new()  # default

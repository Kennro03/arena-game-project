extends Skill
class_name ActiveSkill

signal cast_started(skill: ActiveSkill)
signal cast_interrupted(skill: ActiveSkill)
signal cast_completed(skill: ActiveSkill)

enum InterruptType {
	UNINTERRUPTIBLE,       
	INTERRUPTED_BY_STUN,    # hard CC (stun/silence) stops it
	INTERRUPTED_BY_HIT,     # any hit, silence, or CC interrupts it
}

@export var cooldown: float = 5.0
@export var charges: int = 1
@export var interrupt_type: InterruptType = InterruptType.INTERRUPTED_BY_STUN
@export var refund_cooldown_on_interrupt: bool = false

#@export var targeting: SkillTargeting = null  # how to pick a target
#@export var cast_sequence: Array[CastStep] = []  # ordered visual + mechanical steps

var _current_cooldown: float = 0.0
var _current_charges: int = 0
var _is_casting: bool = false
var _interrupt_requested: bool = false
var _current_step_index: int = 0
var _owner: BaseUnit

func attach(unit: BaseUnit) -> void:
	_owner = unit
	_current_charges = charges

func can_use() -> bool:
	return _current_charges > 0 and _current_cooldown <= 0.0

func _execute_sequence(context: Dictionary) -> void:
	_owner.get_tree().create_tween()  # just to access coroutine-like flow
	_run_steps(context)

func _run_steps(context: Dictionary) -> void:
	# run steps via signal chain rather than await
	# use a recursive callable pattern
	var step_index := 0
	_run_step(step_index, context)

func _run_step(index: int, context: Dictionary) -> void:
	pass
	if _interrupt_requested:
		_on_interrupted()
		return
	#if index >= cast_sequence.size():
	#	_is_casting = false
	#	return
	#var step := cast_sequence[index]
	#step.execute(_owner, context, func():
	#	_run_step(index + 1, context))

func try_interrupt(cause: String = "hit") -> bool:
	if not _is_casting:
		return false
	
	match interrupt_type:
		InterruptType.UNINTERRUPTIBLE:
			return false
		InterruptType.INTERRUPTED_BY_HIT:
			if cause == "hit" or cause == "stun" or cause == "silence":
				_interrupt_requested = true
				return true
			return false
		InterruptType.INTERRUPTED_BY_STUN:
			if cause == "stun" or cause == "silence":
				_interrupt_requested = true
				return true
			return false
	return false

func _on_interrupted() -> void:
	_is_casting = false
	_interrupt_requested = false
	if refund_cooldown_on_interrupt:
		_current_cooldown = 0.0
		_current_charges = charges
	# optional: emit signal for visual feedback
	if _owner:
		_owner.spriteModule.play_hurt()

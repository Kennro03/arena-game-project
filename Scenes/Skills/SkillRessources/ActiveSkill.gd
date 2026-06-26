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

@export var targeting: SkillTargeting = null  # how to pick a target
@export var cast_sequence: Array[CastStep] = []  # ordered visual + mechanical steps
@export var interrupt_animation: String = ""  

var _current_cooldown: float = 0.0
var _current_charges: int = 0
var _is_casting: bool = false
var _interrupt_requested: bool = false
var _owner: BaseUnit

func attach(_unit: BaseUnit) -> void:
	_owner = _unit
	_current_charges = charges

func detach(_unit: BaseUnit) -> void:
	if _is_casting:
		_interrupt_requested = true
	_owner = null

func can_use() -> bool:
	if _owner and _owner.is_silenced:
		return false
	return _current_charges > 0 and _current_cooldown <= 0.0

func use(target: BaseUnit = null) -> void:
	if not can_use():
		return
	cast_started.emit(self)
	_current_charges -= 1
	if _current_charges <= 0:
		_current_cooldown = cooldown
	_is_casting = true
	_interrupt_requested = false
	var context := {"target": target, "caster": _owner}
	_run_step(0, context)

func _run_step(index: int, context: Dictionary) -> void:
	if _interrupt_requested:
		_on_interrupted()
		return
	if index >= cast_sequence.size():
		_is_casting = false
		cast_completed.emit(self)
		return
	var step := cast_sequence[index]
	step.execute(_owner, context, func():
		_run_step(index + 1, context))

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
	cast_interrupted.emit(self)
	if refund_cooldown_on_interrupt:
		_current_cooldown = 0.0
		_current_charges = min(_current_charges + 1, charges)
	# optional: play animation on interrupted
	if _owner and interrupt_animation != "" and _owner.spriteModule.animation_player.has_animation(interrupt_animation):
		_owner.spriteModule.animation_player.play(interrupt_animation)

func tick(delta: float) -> void:
	if _current_cooldown > 0.0:
		_current_cooldown -= delta
		if _current_cooldown <= 0.0:
			_current_cooldown = 0.0
			_current_charges = charges

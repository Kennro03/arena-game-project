extends StatusEffect
class_name StatusEffect_Amplifier

@export var target_status_id: String = "burn"

@export var damage_multiplier: float = 1.0
@export var tick_interval_multiplier: float = 1.0
@export var max_stacks_bonus: int = 0

# reference to effect being amplified
var _amplified_effect: StatusEffect = null

func on_apply(_target, _effect) -> void:
	super.on_apply(_target, _effect)
	_find_and_modify(_target)

func _find_and_modify(_target) -> void:
	if not _target.has_node("StatusEffectModule"):
		return
	for effect in _target.statusEffectModule.StatusEffects:
		if effect.status_ID == target_status_id:
			_apply_modifications(effect)
			_amplified_effect = effect
			return

func _apply_modifications(effect: StatusEffect) -> void:
	if effect is StatusEffect_DoT:
		(effect as StatusEffect_DoT).damage_per_stack *= damage_multiplier
	effect.tick_interval *= tick_interval_multiplier
	effect.max_stacks += max_stacks_bonus

func _remove_modifications(effect: StatusEffect) -> void:
	# reverse the changes on expiry
	if effect is StatusEffect_DoT:
		(effect as StatusEffect_DoT).damage_per_stack /= damage_multiplier
	effect.tick_interval /= tick_interval_multiplier
	effect.max_stacks -= max_stacks_bonus

func on_expire(_target, _effect) -> void:
	if is_instance_valid(_amplified_effect):
		_remove_modifications(_amplified_effect)
	super.on_expire(_target, _effect)

func update(_target, delta) -> bool:
	# expire when the target effect expires
	if _amplified_effect == null or not (_amplified_effect in _target.statusEffectModule.StatusEffects):
		on_expire(_target, self)
		return true
	return super.update(_target, delta)

extends SkillEffect
class_name SkillEffect_ApplyStatusEffect

@export var status_effect: StatusEffect

func _apply_to(_target: Unit, _caster: Unit, _context: Dictionary) -> void:
	_target.statusEffectModule.apply_status_effect(status_effect.duplicate(true))

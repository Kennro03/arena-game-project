extends CastStep
class_name Step_ApplySkillEffect

@export var effects: Array[SkillEffect] = []

func execute(caster: BaseUnit, context: Dictionary, next: Callable) -> void:
	for effect in effects:
		effect.apply(caster, context)
	next.call()

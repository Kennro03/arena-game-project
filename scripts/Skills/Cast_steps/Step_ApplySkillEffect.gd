extends CastStep
class_name Step_ApplySkillEffect

@export var effects: Array[SkillEffect] = []

func execute(caster: Unit, context: Dictionary, next: Callable) -> void:
	for effect in effects:
		effect.apply(caster, context)
	next.call()

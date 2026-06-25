extends CastStep
class_name Step_Delay

@export var duration: float = 0.2

func execute(caster: BaseUnit, _context: Dictionary, next: Callable) -> void:
	caster.get_tree().create_timer(duration).timeout.connect(next)

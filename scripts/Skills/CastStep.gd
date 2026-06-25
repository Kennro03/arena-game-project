extends Resource
class_name CastStep

# next is a Callable() that advances to the next step
func execute(_caster: BaseUnit, _context: Dictionary, _next: Callable) -> void:
	_next.call()  # default: instant, proceed immediately

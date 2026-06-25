extends CastStep
class_name Step_PlayAnimation

@export var animation_name: String = ""
@export var wait_for_finish: bool = true

func execute(caster: BaseUnit, _context: Dictionary, next: Callable) -> void:
	if caster.spriteModule and caster.spriteModule.animation_player.has_animation(animation_name):
		caster.spriteModule.animation_player.play(animation_name)
		if wait_for_finish:
			# connect to animation_finished, then call next
			var ap := caster.spriteModule.animation_player
			ap.animation_finished.connect(func(_name):
				if _name == animation_name:
					ap.animation_finished.disconnect(ap.animation_finished.get_connections()[0]["callable"])
					next.call(), CONNECT_ONE_SHOT)
			return
	next.call()

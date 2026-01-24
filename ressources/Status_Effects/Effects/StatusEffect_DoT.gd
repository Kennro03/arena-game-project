extends StatusEffect
class_name StatusEffect_DoT

signal emit_particle(particle_scene:PackedScene)

@export var damage_per_stack : float = 2.0
@export var particle_effect : PackedScene

var total_damage : float = 0.0

func on_tick(_target, _effect):
	var dmg : float = stacks * damage_per_stack
	if _target.has_method("take_damage"):
		#print("Dealing DOT " + str(_target.display_name) + "for " + str(dmg) + " damage" )
		_target.take_damage(dmg)
		total_damage += dmg
	
	if particle_effect :
		emit_particle.emit(particle_effect)

func on_expire(_target, _effect):
	#print(str(Status_effect_name) + " DoT status effect duration ended, dealt a total of " + str(total_damage) + " damage")
	pass

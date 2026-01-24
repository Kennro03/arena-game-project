extends StatusEffect
class_name StatusEffect_BurstOnStack

signal emit_particle(particle_scene:PackedScene)

@export var damage_per_stack : float = 2.0
@export var damage_mult_full_stack : float = 1.25
@export var particle_effect : PackedScene

var total_damage : float = 0.0

func on_stack_changed(_target, _effect): 
	#print(str(Status_effect_name) + " changed stacks to " + str(stacks))
	if stacks == max_stacks :
		if _target.has_method("take_damage"):
			var dmg : float = stacks * damage_per_stack * damage_mult_full_stack
			_target.take_damage(dmg)
			total_damage += dmg
			#print("Dealing burst " + str(_target.display_name) + "for " + str(dmg) + " damage" )
		
		if particle_effect :
			emit_particle.emit(particle_effect)
		
		elapsed = duration
		stacks = 0

func on_expire(_target, _effect):
	#print("Effect expired")
	if stacks > 0 :
		if _target.has_method("take_damage"):
			var dmg : float = stacks * damage_per_stack
			_target.take_damage(dmg)
			total_damage += dmg
			#print("Dealing burst " + str(_target.display_name) + "for " + str(dmg) + " damage" )
		
		if particle_effect :
			emit_particle.emit(particle_effect)

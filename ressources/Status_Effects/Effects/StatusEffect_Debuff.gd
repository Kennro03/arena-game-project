extends StatusEffect
class_name StatusEffect_Debuff

signal emit_particle(particle_scene:PackedScene)
signal stop_particle(particle_scene:PackedScene)

@export var debuff : StatBuff
@export var particle_effect : PackedScene

func on_apply(_target, _effect):
	#print("Applying " + str(Status_effect_name))
	stacks += max(0, _effect.stacks_affliction)
	if debuff :
		#print("Applying " + str(Status_effect_name) + " debuff = " + str(debuff))
		_target.stats.add_buff(debuff)
	if particle_effect :
		#print("Emitting particle effect slow ")
		emit_particle.emit(particle_effect)

func on_expire(_target, _effect):
	#print("Target stat buffs list = " + str(_target.stats.stat_buffs))
	if _target.stats.stat_buffs.has(debuff) :
		_target.stats.remove_buff(debuff)
	if particle_effect :
		stop_particle.emit(particle_effect)

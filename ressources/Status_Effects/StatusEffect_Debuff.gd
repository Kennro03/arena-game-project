extends StatusEffect
class_name StatusEffect_Debuff

@export var debuff : StatBuff

func on_apply(_target, _effect):
	#print("Applying " + str(Status_effect_name))
	stacks += max(0, _effect.stacks_affliction)
	if debuff :
		#print("Applying " + str(Status_effect_name) + " debuff = " + str(debuff))
		_target.stats.add_buff(debuff)

func on_expire(_target, _effect):
	#print("Target stat buffs list = " + str(_target.stats.stat_buffs))
	if _target.stats.stat_buffs.has(debuff) :
		_target.stats.remove_buff(debuff)
		#print(str(Status_effect_name) + " removed debuff = " + str(debuff))
		#print("Target stat buffs list = " + str(_target.stats.stat_buffs))

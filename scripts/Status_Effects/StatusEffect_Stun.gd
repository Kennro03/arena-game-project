extends StatusEffect
class_name StatusEffect_Stun


func on_apply(_target, _effect):
	#print("Applying " + str(Status_effect_name))
	stacks += max(0, _effect.stacks_affliction)
	_target.is_stunned = true

func on_expire(_target, _effect):
	_target.is_stunned = false
	#print("Target stun status after expiring = " + str(_target.is_stunned))

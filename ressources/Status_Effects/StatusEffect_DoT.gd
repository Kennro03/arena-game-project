extends StatusEffect
class_name StatusEffect_DoT

@export var damage_per_stack : float = 2.0

var total_damage : float = 0.0

func on_tick(_target, _effect):
	var dmg : float = stacks * damage_per_stack
	if _target.has_method("take_damage"):
		#print("Burning " + str(_target.display_name) + "for " + str(dmg) + " damage" )
		_target.take_damage(dmg)
		total_damage += dmg

func on_expire(_target, _effect):
	#print(str(Status_effect_name) + " DoT status effect ended, dealt a total of " + str(total_damage) + " damage")
	pass

extends StatusEffect
class_name Status_Burning

@export var damage_per_stack : float = 2.0

var total_damage : float = 0.0

func on_apply(_target, _effect):
	stacks = max(1, stacks)

func on_tick(_target, _effect):
	var dmg : float = stacks * damage_per_stack
	if _target.has_method("take_damage"):
		_target.take_damage(dmg)
		total_damage += dmg

func on_expire(_target, _effect):
	print("Burning status effect ended, dealt a total of " + str(total_damage) + " damage")

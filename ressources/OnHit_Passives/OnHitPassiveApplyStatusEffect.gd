extends OnHitPassive
class_name OnHitPassiveApplyStatusEffect

@export var status_effects : Array[StatusEffect]
@export var apply_chance := 1.0  # 0..1 chance

func on_hit(hit : HitData) -> void:
	if randf() > apply_chance:
		#Generates a random number between 0 and 1, if bigger than apply_chance then don't apply statuses
		return
	if status_effects == null:
		return
	
	for status_effect in status_effects : 
		var to_add = status_effect.duplicate(true)
		hit.status_effects.append(to_add)

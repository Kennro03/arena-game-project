extends OnHitPassive
class_name ShieldOnHit

@export var shield_amount : float = 10.0
@export var only_on_crit := false

func on_hit(hit: HitData) -> void:
	if only_on_crit and not hit.is_critical:
		return
	hit.hit_owner.stats.shield += shield_amount
	#print("Shielded " + str(hit.hit_owner) + " for " + str(shield_amount))

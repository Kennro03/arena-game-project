extends OnHitEffect
class_name ShieldOnHit

@export var shield_amount : float = 10.0
@export var only_on_crit := false

func on_hit(hit: HitData) -> void:
	if only_on_crit and not hit.is_critical:
		return
	hit.attacker.add_shield(shield_amount)

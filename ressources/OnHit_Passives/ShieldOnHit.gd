extends OnHitPassive
class_name ShieldOnHit

@export var shield_amount : float = 10.0

func _on_hit_effect(hit: HitData) -> void:
	hit.hit_owner.stats.shield += shield_amount
	#print("Shielded " + str(hit.hit_owner) + " for " + str(shield_amount))

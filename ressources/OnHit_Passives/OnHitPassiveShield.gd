extends OnHitPassive
class_name OnHitPassiveShield

@export var shield_amount : float = 10.0

func _init() -> void:
	onhit_passive_ID = UIDGenerator.generate("onhit_shield_passive")

func _on_hit_effect(hit: HitData) -> void:
	hit.hit_owner.stats.shield += shield_amount
	#print("Shielded " + str(hit.hit_owner) + " for " + str(shield_amount))

func _generate_metadata():
	if onhit_passive_name == "" :
		onhit_passive_name = "On-hit " + str(shield_amount) + "_Shield"
	if onhit_passive_ID == "" :
		#THIS DOES NOT GENERATE A UNIQUE ID, CHANGE THIS LATER
		onhit_passive_ID = UIDGenerator.generate("onhit_shield_passive")
		#print("Generated OnHitPassiveApplyStatusEffects id = " + onhit_passive_ID)
	if onhit_passive_description == "" :
		onhit_passive_description = "A onHit passive that gives the user shield upon certain hits." 
		
		#print("Generated OnHitPassiveApplyStatusEffects description = " + onhit_passive_description)

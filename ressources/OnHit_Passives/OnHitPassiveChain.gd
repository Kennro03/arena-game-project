extends OnHitPassive
class_name OnHitPassiveChain

@export var apply_chance := 1.0  # 0..1 chance to proc
@export var number_of_targets : int = 1  # number of extra targets hit by the chain
@export var reuse_targets : bool = false # wheter targets can be hit again
@export var link_texture : Texture2D = preload("res://ressources/Sprites/VFX/placeholder-link.png")
@export var chain_duration : float = 0.75 # time the chain remains before disapearing

var hit_data : HitData

func on_hit(hit : HitData) -> void:
	var owner := hit.hit_owner
	var closest_target : Node2D
	var chain_targets : Array[Node2D] = []
	
	if number_of_targets >= 1 and randf() > apply_chance:
		if owner.has_method("get_closest_unit") :
			var i:= number_of_targets
			var link: Line2D = preload("res://Scenes/VFX/link.tscn").instantiate()
			link.texture = link_texture
			
			while i > 0 :
				closest_target = owner.get_closest_unit(
					owner.get_units_in_group("Units"),
					INF,
					func(u): return not owner.check_if_ally(u))
				chain_targets.append(closest_target)
				i -= 1
			
			for target in chain_targets :
				
				pass
		
	

func setup(_name : String = "", _id : String  = "", _description : String  = "", _icon : Texture2D = PlaceholderTexture2D.new() ) -> void : 
	onhit_passive_name = _name
	onhit_passive_ID = _id
	onhit_passive_description = _description
	onhit_passive_icon = _icon
	_generate_metadata()

func _generate_metadata():
	if onhit_passive_name == "" :
		onhit_passive_name = "On-hit " + str(number_of_targets) + "_target_chain"
	if onhit_passive_ID == "" :
		#THIS DOES NOT GENERATE A UNIQUE ID, CHANGE THIS LATER
		onhit_passive_ID = str(randi_range(1,9999999))
		#print("Generated OnHitPassiveApplyStatusEffects id = " + onhit_passive_ID)
	if onhit_passive_description == "" :
		onhit_passive_description = "A onHit passive that chains the hit to nearby targets, has : " 
		onhit_passive_description += "\n" + str(apply_chance*100) + "% chance to proc"
		onhit_passive_description += "\nspreads to " + str(number_of_targets) + " targets"
		if reuse_targets : 
			onhit_passive_description += "\ncan reuse targets "
		else :
			onhit_passive_description += "\ncannot reuse targets "
		
		#print("Generated OnHitPassiveApplyStatusEffects description = " + onhit_passive_description)

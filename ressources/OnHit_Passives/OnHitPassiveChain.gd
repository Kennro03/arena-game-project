extends OnHitPassive
class_name OnHitPassiveChain

@export var apply_chance := 1.0  # 0..1 chance to proc
@export var number_of_targets : int = 1  # number of extra targets hit by the chain
@export var reuse_targets : bool = false # wheter targets can be hit again
@export var link_texture : Texture2D = preload("res://ressources/Sprites/VFX/placeholder-link.png")
@export var chain_duration : float = 0.75 # time the chain texture remains before disapearing

@export var chain_range : float

@export var damage : float 

func on_hit(hit : HitData) -> void:
	var owner := hit.hit_owner
	var closest_target : Node2D
	var chain_targets : Array[Node2D] = []
	var pts : PackedVector2Array = []
	
	print("Chain effect launched") 
	
	if number_of_targets >= 1 and randf() < apply_chance:
		var t:= number_of_targets+1 
		
		if owner.has_method("get_closest_unit") :
			var link: Link = preload("res://Scenes/VFX/link.tscn").instantiate()
			link.duration = chain_duration
			link.texture = link_texture
			
			while t > 0 :
				if !reuse_targets : 
					#Only get targets not already in the target list
					closest_target = owner.get_closest_unit(
						owner.get_units_in_group("Units").filter(func(element): return element not in chain_targets),
						chain_range if chain_range else INF,
						func(u): return not owner.check_if_ally(u))
				else : 
					#Only get that aren't the last target in the target list
					closest_target = owner.get_closest_unit(
						owner.get_units_in_group("Units").filter(func(element): return element != chain_targets[-1]),
						chain_range if chain_range else INF,
						func(u): return not owner.check_if_ally(u))
				chain_targets.append(closest_target)
				t -= 1
			
			print("Chain effect " + str(onhit_passive_name) + " selected following targets = " + str(chain_targets))
			link.targets = chain_targets
			for target in chain_targets :
				if target :
					if target.has_method("resolve_hit") :
						if target != chain_targets[0] :
							if damage :
								target.take_damage(damage)
							else : 
								target.resolve_hit(hit)
				else : 
					printerr("did not find a target!")
			
			link.points = pts
			owner.get_tree().root.add_child(link)
			link.queue_redraw()

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

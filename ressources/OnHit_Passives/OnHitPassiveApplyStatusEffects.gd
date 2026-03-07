extends OnHitPassive
class_name OnHitPassiveApplyStatusEffects

@export var status_effects : Array[StatusEffect]
@export var apply_chance := 1.0  # 0..1 chance
@export var apply_to_self : bool = false #if true, status effects are applied to self on hit

func _on_hit_effect(hit : HitData) -> void:
	if randf() > apply_chance:
		#Generates a random number between 0 and 1, if bigger than apply_chance then don't apply statuses
		return
	
	if status_effects == null:
		return
	
	if apply_to_self == false : 
		for status_effect in status_effects : 
			var to_add = status_effect.duplicate(true)
			hit.status_effects.append(to_add)
	else : 
		for status_effect in status_effects :
			hit.hit_owner.statusEffectModule.apply_status_effect(status_effect)

func _init() -> void:
	onhit_passive_ID = UIDGenerator.generate("onhit_status_passive")

func setup(_status_effects : Array[StatusEffect] = [], _name : String = "", _id : String  = "", _description : String  = "", _icon : Texture2D = PlaceholderTexture2D.new() ) -> OnHitPassiveApplyStatusEffects : 
	status_effects = _status_effects
	onhit_passive_name = _name
	onhit_passive_ID = _id
	onhit_passive_description = _description
	onhit_passive_icon = _icon
	_generate_metadata()
	return self

func _generate_metadata():
	var effect_names := " & ".join(status_effects.map(func(e): return e.Status_effect_name))
	
	if onhit_passive_name == "" :
		for i in status_effects.size():
			onhit_passive_name += status_effects[i].Status_effect_name
			if i < status_effects.size() - 1:
				onhit_passive_name += " & "
	
	if onhit_passive_ID == "" :
		#THIS DOES NOT GENERATE A UNIQUE ID, CHANGE THIS LATER
		onhit_passive_ID = UIDGenerator.generate("onhit_status_passive")
	
	if onhit_passive_description == "" :
		onhit_passive_description = "A onHit passive that inflicts: " + effect_names.replace(" & ", ", ")
		#print("Generated OnHitPassiveApplyStatusEffects description = " + onhit_passive_description)

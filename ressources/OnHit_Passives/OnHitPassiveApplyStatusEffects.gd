extends OnHitPassive
class_name OnHitPassiveApplyStatusEffects

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

func setup(_status_effects : Array[StatusEffect] = [], _name : String = "", _id : String  = "", _description : String  = "", _icon : Texture2D = PlaceholderTexture2D.new() ) -> void : 
	status_effects = _status_effects
	onhit_passive_name = _name
	onhit_passive_ID = _id
	onhit_passive_description = _description
	onhit_passive_icon = _icon
	_generate_metadata()

func _generate_metadata():
	if onhit_passive_name == "" :
		for i in status_effects.size():
			onhit_passive_name += status_effects[i].Status_effect_name
			if i < status_effects.size() - 1:
				onhit_passive_name += " & "
	if onhit_passive_ID == "" :
		#THIS DOES NOT GENERATE A UNIQUE ID, CHANGE THIS LATER
		onhit_passive_ID = str(randi_range(1,9999999))
		print("Generated OnHitPassiveApplyStatusEffects id = " + onhit_passive_ID)
	if onhit_passive_description == "" :
		onhit_passive_description = "A onHit passive that inflicts the following status effects : "
		for i in status_effects.size():
			onhit_passive_description += status_effects[i].Status_effect_name
			if i < status_effects.size() - 1:
				onhit_passive_name += ", "
		print("Generated OnHitPassiveApplyStatusEffects description = " + onhit_passive_description)

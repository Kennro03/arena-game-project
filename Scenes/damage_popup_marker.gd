extends Marker2D
@export var DamagePopupNode : PackedScene

func damage_popup(popupdamage: String, textscale : float = 1.0) : 
	if DamagePopupNode != null :
		var damage_popup_label = DamagePopupNode.instantiate()
		var tween = get_tree().create_tween()
		
		damage_popup_label.position = owner.find_child("DamagePopupMarker").global_position
		tween.tween_property(damage_popup_label,"position",global_position + get_direction(),0.75)
		
		damage_popup_label.scale = Vector2(textscale, textscale)
		damage_popup_label.find_child("Label").text = popupdamage
		get_tree().current_scene.add_child(damage_popup_label)
	else :
		printerr("Damage Popup Scene not assigned !")

func get_direction() :
	return Vector2(randf_range(-1,1), -randf()) * 16

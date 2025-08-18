extends Marker2D
@export var DamagePopupNode : PackedScene



func damage_popup(popupdamage: float) : 
	if DamagePopupNode != null :
		var damage_popup = DamagePopupNode.instantiate()
		var tween = get_tree().create_tween()
		
		damage_popup.position = owner.find_child("DamagePopupMarker").global_position
		
		tween.tween_property(damage_popup,"position",global_position + get_direction(),0.75)
		damage_popup.find_child("Label").text = str(popupdamage)
		get_tree().current_scene.add_child(damage_popup)
	else :
		printerr("Damage Popup Scene not assigned !")

func get_direction() :
	return Vector2(randf_range(-1,1), -randf()) * 16

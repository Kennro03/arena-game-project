extends Marker2D
@export var DamagePopupNode : PackedScene


func damage_popup(popupdamage: float) : 
	if DamagePopupNode != null :
		var damage_popup = DamagePopupNode.instantiate()
		damage_popup.position = owner.find_child("DamagePopupMarker").global_position
		damage_popup.find_child("Label").text = str(popupdamage)
		get_tree().current_scene.add_child(damage_popup)
	else :
		printerr("Damage Popup Scene not assigned !")

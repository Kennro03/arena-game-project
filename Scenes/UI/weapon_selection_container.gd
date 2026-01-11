extends HBoxContainer

@export var weapon_list : Array[Weapon] = []

func _ready() -> void:
	load_weapons()
	for t in weapon_list :
		#print("Adding weapon " + t.weaponName + " to weapon selector")
		%WeaponOptions.add_item(t.weaponName)
		pass

func load_weapons():
	if weapon_list == [] :
		for file_name in DirAccess.get_files_at("res://ressources/Weapons/"):
			if (file_name.get_extension() == "tres"):
				weapon_list.append(load("res://ressources/Weapons/"+file_name) )

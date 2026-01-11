extends HBoxContainer

@export var weapon_list : Array[Weapon] = [
	preload("res://Scenes/Weapons/fists.tres"),
	preload("res://Scenes/Weapons/testdagger.tres"),
	preload("res://Scenes/Weapons/testsword.tres"),
	preload("res://Scenes/Weapons/testhammer.tres"),
]

func _ready() -> void:
	for t in weapon_list :
		#print("Adding team " + t.team_name + " to team selector")
		%WeaponOptions.add_item(t.weaponName)
		pass

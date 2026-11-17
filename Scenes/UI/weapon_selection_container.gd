extends HBoxContainer

@export var weapon_list : Array[Weapon] = []


func _ready() -> void:
	load_weapons()
	for t in weapon_list :
		#print("Adding weapon " + t.item_name + " to weapon selector")
		%WeaponOptions.add_item(t.item_name)

func load_weapons() -> void:
	if weapon_list == [] :
		for res in ResourceScan.load_all(UnitData.WEAPONS_DIR):
			if res is Weapon:
				weapon_list.append(res)

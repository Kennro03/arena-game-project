extends UnitData
class_name humanoidUnitData

func _init() -> void:
	unit_scene = preload("res://Scenes/Units/Humanoid/humanoid_unit.tscn")
	id = UIDGenerator.generate("Humanoid")
	display_name = name_registry.get_random_name("humanoid")
	unit_type = "Humanoid"
	description = "A humanoid unit."
	default_weapon = preload("uid://dfscer2qw0fdp").duplicate(true)
	weapon = default_weapon.duplicate(true)  
	icon = preload("uid://ccpr8mltdglbp")

func _make_copy() -> humanoidUnitData:
	var copy : humanoidUnitData = humanoidUnitData.new()
	copy.id = id
	copy.display_name = display_name
	copy.description = description
	copy.show_name = show_name
	copy.show_health = show_health
	copy.icon = icon
	copy.color = color
	copy.team = team
	copy.stats = stats.duplicate(true)
	copy.weapon = weapon.duplicate(true) if weapon else null
	copy.default_weapon = default_weapon
	copy.armor = armor.duplicate(true) if armor else null
	copy.accessories = accessories
	copy.accessory_limit = accessory_limit
	copy.skill_list = skill_list.duplicate(true)
	copy.random_seed = random_seed
	return copy

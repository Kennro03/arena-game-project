extends UnitData
class_name stickmanUnitData

func _init() -> void:
	unit_scene = preload("res://Scenes/Units/Stickman/stickman.tscn")
	id = UIDGenerator.generate("Stickman")
	display_name = "Stickman"
	description = "A regular stickman."
	default_weapon = preload("uid://dfscer2qw0fdp").duplicate(true)
	weapon = default_weapon.duplicate(true)  

func _make_copy() -> stickmanUnitData:
	var copy : stickmanUnitData = stickmanUnitData.new()
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
	copy.skill_list = skill_list.duplicate(true)
	copy.random_seed = random_seed
	return copy

extends UnitData
class_name stickmanUnitData

func _init() -> void:
	unit_scene = preload("res://Scenes/Units/Stickman/stickman.tscn")
	id = UIDGenerator.generate("Stickman")
	display_name = "Stickman"
	description = "A regular stickman."
	default_weapon = preload("res://ressources/Weapons/fists.tres").duplicate(true)

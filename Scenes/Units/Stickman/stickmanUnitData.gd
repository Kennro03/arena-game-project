extends UnitData
class_name stickmanUnitData

func _init() -> void:
	id = UIDGenerator.generate("Stickman")
	display_name = "Stickman"
	description = "A regular stickman."
	weapon = preload("res://ressources/Weapons/fists.tres").duplicate(true)

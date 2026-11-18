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

# _make_copy() is inherited from UnitData (copies every field, including attribute_weights).

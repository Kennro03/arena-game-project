extends BaseUnit
class_name Humanoid

func _ready() -> void:
	unit_type = "Humanoid"
	super._ready()
	spriteModule.update_sprites()

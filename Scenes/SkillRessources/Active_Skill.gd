extends Skill
class_name Active_Skill

@export var icon: Texture2D 
@export var cooldown: float = 10.0
@export var activation_time: float = 0.5
@export var components : Array[SkillEffect]

func activate(caster: Node2D, targets: Array[Node], context: Dictionary = {}) -> void :
	# Default behavior — can be overridden
	if check_conditions() == true : 
		print("activated skill")
	pass

func check_conditions(context: Dictionary = {}) -> bool :
	# Default behavior — can be overridden
	return true

extends Skill
class_name Passive_Skill


func activate(caster: Node2D) -> void :
	# Default behavior — can be overridden
	if check_conditions(caster) == true : 
		print("activated passive skill")
	pass

func check_conditions(caster: Node2D) -> bool :
	# Default behavior — can be overridden
	return true

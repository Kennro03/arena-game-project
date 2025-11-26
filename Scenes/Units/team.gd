extends Resource
class_name Team

static var registry: Array[Team] = []

@export var team_name : String:
	get:
		return team_name
	set(value):
		team_name = value
@export var team_color : Color:
	get:
		return team_color
	set(value):
		team_color = value
@export var flagVisible : bool = true

func _init(name, RGB_color,showFlag : bool = false) -> void:
	team_name = name
	team_color = RGB_color
	flagVisible = showFlag
	Team.registry.append(self)

func get_team(name = "", RGB_color = Color()) -> Team :
	if name :
		return registry.filter(func(t): return t.team_name == name)[0]
	elif RGB_color : 
		return registry.filter(func(t): return t.team_color == RGB_color)[0]
	else :
		printerr("Could not find Team !")
		return null

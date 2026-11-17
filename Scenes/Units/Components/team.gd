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

func _init(name = "", RGB_color:Color = Color.WHITE,showFlag : bool = false) -> void:
	if name == "":  # avoid adding blank teams to registry on duplicate()
		return
	team_name = name
	team_color = RGB_color
	flagVisible = showFlag

static func create(name: String, RGB_color: Color, showFlag: bool = true) -> Team:
	var t := Team.new(name, RGB_color, showFlag)
	Team.registry.append(t)
	return t


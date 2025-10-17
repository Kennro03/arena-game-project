class_name Team extends Resource

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

func _init(name, RGB_color) -> void:
	team_name = name
	team_color = RGB_color

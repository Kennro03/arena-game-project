extends HBoxContainer

func _ready() -> void:
	Team.create("Red",Color.RED)
	Team.create("Blue",Color.BLUE)
	Team.create("Green",Color.GREEN)
	
	for t in Team.registry :
		#print("Adding team " + t.team_name + " to team selector")
		%TeamOptions.add_item(t.team_name)
		pass

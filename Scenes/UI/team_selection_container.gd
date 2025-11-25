extends HBoxContainer

func _ready() -> void:
	for t in Team.registry :
		#print("Adding team " + t.team_name + " to team selector")
		%TeamOptions.add_item(t.team_name)
		pass

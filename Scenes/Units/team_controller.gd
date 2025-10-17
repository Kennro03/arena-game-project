extends Node
@export var flag: PackedScene
var flag_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner.team != null :
		#print("Stickman has a team, adding flag.")
		flag_instance = flag.instantiate()
		flag_instance.modulate = owner.team.team_color
		add_child(flag_instance)

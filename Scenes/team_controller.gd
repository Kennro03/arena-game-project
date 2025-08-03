extends Node
@export var flag: PackedScene
var flag_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner.team != null :
		print("Adding flag.")
		flag_instance = flag.instantiate()
		flag_instance.modulate = owner.team.team_color
		add_child(flag_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	flag_instance.position = owner.position + Vector2(0,-80)
	pass

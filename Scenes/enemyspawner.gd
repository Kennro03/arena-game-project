extends Node
@export var stickman: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT :
			print("Spawned a stickman at " + str(event.position))
			spawn_stickman(event.position)

func spawn_stickman(pos: Vector2):
	if stickman == null:
		push_error("No stickman scene assigned!")
		return
	
	var stickman_instance = stickman.instantiate()
	stickman_instance.position = pos
	get_parent().add_child(stickman_instance)

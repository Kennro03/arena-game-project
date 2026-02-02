extends Line2D
class_name Link

@export var duration : float = 1.0
var targets: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Spawned, width = " + str(width))
	await get_tree().create_timer(duration).timeout
	#print("Link timed out, despawning")
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	clear_points()
	for t in targets:
		if t:
			add_point(to_local(t.global_position))

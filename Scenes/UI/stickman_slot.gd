extends Button
@export var stickman_data: Stickman 

signal stickman_selected(_stickman_data: Stickman)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon = load("res://ressources/Sprites/flag.png")
	tooltip_text = stickman_data.type
	connect("pressed", Callable(self, "_on_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("stickman_selected", stickman_data)

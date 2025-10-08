extends Button
class_name Slot
@export var stickman_data: StickmanData

signal stickman_selected(_stickman_data: Stickman)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stickman_data :
		%StickmanSpriteIcon.texture = load("res://ressources/Sprites/Stickman White Tpose.png")
		%StickmanSpriteIcon.modulate = stickman_data.color
	else : 
		%StickmanSpriteIcon.visible = false
	connect("pressed", Callable(self, "_on_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("stickman_selected", stickman_data)
	#if stickman_data :
		#print("Type : " + stickman_data.type)

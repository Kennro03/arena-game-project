extends Button
class_name Slot
@export var stickman_data: StickmanData = null

signal stickman_selected(_stickman_data: Stickman)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_sprite()
	connect("pressed", Callable(self, "_on_pressed"))

func _process(_delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("stickman_selected", stickman_data)
	
	#if stickman_data :
		#print("Type : " + stickman_data.type)
		

func update_sprite() :
	if stickman_data :
		%StickmanSpriteIcon.texture = load("res://ressources/Sprites/Units/Stickman White Tpose.png")
		%StickmanSpriteIcon.modulate = stickman_data.color
		%StickmanSpriteIcon.visible = true
	else : 
		%StickmanSpriteIcon.visible = false

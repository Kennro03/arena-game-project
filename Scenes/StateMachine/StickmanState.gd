class_name StickmanState extends State

const IDLE = "Idle"
const MOVING = "Moving"
const ATTACKING = "Attacking"
const DYING = "Dying"

var stickman: Stickman


func _ready() -> void:
	await owner.ready
	stickman = owner as Stickman
	assert(stickman != null, "The PlayerState state type must be used only in the stickman scene. It needs the owner to be a node2D.")

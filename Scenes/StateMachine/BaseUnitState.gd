extends State
class_name BaseUnitState 

const IDLE = "Idle"
const MOVING = "Moving"
const ATTACKING = "Attacking"
const DYING = "Dying"
const CASTING = "Casting"
const STUNNED = "Stunned"

var _BaseUnit: BaseUnit

func _ready() -> void:
	await owner.ready
	_BaseUnit = owner as BaseUnit
	assert(_BaseUnit != null, "The PlayerState state type must be used only in the stickman scene. It needs the owner to be a node2D.")

extends State
class_name BaseUnitState 

const IDLE = "Idle"
const MOVING = "Moving"
const ATTACKING = "Attacking"
const DYING = "Dying"
const CASTING = "Casting"
const STUNNED = "Stunned"
const DOWNED = "Downed"

var unit: BaseUnit

func _ready() -> void:
	await owner.ready
	unit = owner as BaseUnit
	assert(unit != null, "The PlayerState state type must be used only in the unit scene. It needs the owner to be a BaseUnit.")

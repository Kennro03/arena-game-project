extends State
class_name UnitState 

const IDLE = "Idle"
const MOVING = "Moving"
const ENGAGED = "Engaged"
const DYING = "Dying"
const CASTING = "Casting"
const STUNNED = "Stunned"
const DOWNED = "Downed"
const DODGING = "Dodging"

const CYCLING_ANIMATIONS = "Cycling_animations"

var unit: Unit

func _ready() -> void:
	await owner.ready
	unit = owner as Unit
	assert(unit != null, "The PlayerState state type must be used only in the unit scene. It needs the owner to be a Unit.")

func _find_enemy() -> Unit:
	return unit.get_closest_unit(
		unit.get_units_in_group("Live_Units"),
		INF,
		func(u): return not unit.check_if_ally(u)) as Unit

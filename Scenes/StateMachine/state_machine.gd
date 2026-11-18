extends Node
class_name UnitStateMachine 

@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()
@onready var unit: Unit = owner

func is_in_state(state_name: String) -> bool:
	return state.name == state_name

func current_state_name() -> String:
	return state.name

func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	await owner.ready
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	unit.last_attack_time += delta
	if !unit.is_downed :
		unit.stats.health += unit.stats.current_health_regen * delta
	state.update(delta)
	if unit.active == false :
		return
	unit.skillModule._tick(delta)

func _physics_process(delta: float) -> void:
	%Hurtbox.body_knockback()
	state.physics_update(delta)
	# Velocity/acceleration for aim prediction are measured by MovementController.


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(unit.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	# Nothing but a revive can take a unit out of Downed.
	if state.name == UnitState.DOWNED and not data.get("revive", false):
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

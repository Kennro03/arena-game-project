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

var last_position : Vector2

func _physics_process(delta: float) -> void:
	var prev_position : Vector2 = unit.global_position
	unit.previous_velocity = unit.velocity
	
	%Hurtbox.body_knockback()
	
	state.physics_update(delta)
	
	var raw_velocity : Vector2 = (unit.global_position - prev_position) / delta
	unit.velocity = unit.velocity.lerp(raw_velocity, 0.2)
	unit.acceleration = (unit.velocity - unit.previous_velocity) / delta
	
	unit.movement_direction = unit.velocity.normalized() if unit.velocity.length() > 0.1 else unit.movement_direction


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(unit.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

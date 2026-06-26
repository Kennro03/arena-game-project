extends Node
class_name BaseUnitStateMachine 

@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

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
	owner.last_attack_time += delta
	owner.stats.health += owner.stats.current_health_regen * delta
	state.update(delta)
	var unit : BaseUnit = owner
	if !unit.active :
		return
	unit.skillModule._tick(delta)

var last_position : Vector2

func _physics_process(delta: float) -> void:
	var prev_position : Vector2 = owner.global_position
	owner.previous_velocity = owner.velocity
	
	%Hurtbox.body_knockback()
	#border_knockback()
	
	if owner.knockback_velocity.length() > 0.1:
		owner.position += owner.knockback_velocity * delta
		owner.knockback_velocity = owner.knockback_velocity.move_toward(Vector2.ZERO, owner.knockback_decay * delta)
	
	state.physics_update(delta)
	
	var raw_velocity : Vector2 = (owner.global_position - prev_position) / delta
	owner.velocity = owner.velocity.lerp(raw_velocity, 0.2)
	owner.acceleration = (owner.velocity - owner.previous_velocity) / delta
	
	owner.movement_direction = owner.velocity.normalized() if owner.velocity.length() > 0.1 else owner.movement_direction


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

func border_knockback() -> void:
	if owner.position.x > 640.0 :
		owner.apply_knockback(owner,Vector2(-1,0),500)
	elif owner.position.x < 0.0 :
		owner.apply_knockback(owner,Vector2(1,0),500)
	if owner.position.y > 360.0 :
		owner.apply_knockback(owner,Vector2(0,-1),500)
	elif owner.position.y < 0.0 :
		owner.apply_knockback(owner,Vector2(0,1),500)

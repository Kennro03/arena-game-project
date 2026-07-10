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
	var bounds := Rect2(0, 0, 640, 360)
	var owner_pos : BaseUnit = owner.global_position
	var push := Vector2.ZERO
	
	if owner_pos.x > bounds.end.x:
		push.x = -1
	elif owner_pos.x < bounds.position.x:
		push.x = 1
	if owner_pos.y > bounds.end.y:
		push.y = -1
	elif owner_pos.y < bounds.position.y:
		push.y = 1
	
	if push != Vector2.ZERO:
		owner.apply_knockback(owner, push.normalized(), 500.0)

class_name StateMachine extends Node

@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	await owner.ready
	
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	owner.health += owner.health_regen * delta
	owner.update_health()
	state.update(delta)


func _physics_process(delta: float) -> void:
	stickman_body_knockback()
	border_knockback()
	
	if owner.knockback_velocity.length() > 0.1:
		owner.position += owner.knockback_velocity * delta
		owner.knockback_velocity = owner.knockback_velocity.move_toward(Vector2.ZERO, owner.knockback_decay * delta)
	
	state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

func stickman_body_knockback() -> void:
	for targetarea in owner.get_overlapping_areas_in_area(owner.find_child("Hurtbox"),"Hurtbox") : 
		owner.apply_knockback(targetarea.owner, targetarea.owner.position - owner.position , 10.0)

func border_knockback() -> void:
	if owner.position.x > 1152.0 :
		owner.apply_knockback(owner,Vector2(-1,0),500)
	elif owner.position.x < 0.0 :
		owner.apply_knockback(owner,Vector2(1,0),500)
	if owner.position.y > 648.0 :
		owner.apply_knockback(owner,Vector2(0,-1),500)
	elif owner.position.y < 0.0 :
		owner.apply_knockback(owner,Vector2(0,1),500)

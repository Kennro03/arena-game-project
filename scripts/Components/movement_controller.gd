# MovementController.gd
class_name MovementController
extends Node

## Manages all movement for a CharacterBody2D unit.
## Attach as a direct child. The unit must also have a NavigationAgent2D child.

# ── Signals ──────────────────────────────────────────────────────────────────
signal job_completed(type: JobType)
signal knocked_back_finished
signal sequence_step_completed(step_index: int)
signal sequence_completed
## Emitted each tick a movement direction is known, unless facing_locked.
signal facing_updated(direction: Vector2)

# ── Priority ──────────────────────────────────────────────────────────────────
enum JobType {
	NONE        = 0,
	REPOSITION  = 1,  ## Idle orbit — dropped by anything
	NAVIGATE    = 2,  ## Pathfound walk
	DASH        = 3,  ## Direct movement, stops on collision
	SEQUENCE    = 4,  ## Scripted skill movement
	KNOCKBACK   = 5,  ## Cannot be overridden
}

# ── Job inner classes ─────────────────────────────────────────────────────────
class Job:
	var type: JobType = JobType.NONE

class NavigateJob extends Job:
	var destination: Vector2
	var speed: float
	var arrival_radius: float
	func _init(dest: Vector2, spd: float, radius: float) -> void:
		type = JobType.NAVIGATE
		destination = dest;  speed = spd;  arrival_radius = radius

class DashJob extends Job:
	var destination: Vector2
	var speed: float
	var updates_facing: bool
	func _init(dest: Vector2, spd: float, facing: bool = true) -> void:
		type = JobType.DASH
		destination = dest;  speed = spd;  updates_facing = facing

class KnockbackJob extends Job:
	var velocity: Vector2
	var deceleration: float
	var max_distance: float
	var max_duration: float
	var start_pos: Vector2
	var elapsed: float = 0.0
	func _init(vel: Vector2, decel: float, max_dist: float = INF, max_dur: float = INF) -> void:
		type = JobType.KNOCKBACK
		velocity = vel;  deceleration = decel;  max_distance = max_dist;  max_duration = max_dur

class RepositionJob extends Job:
	var center: Vector2
	var radius: float
	var speed_factor: float
	var clockwise: bool

	func _init(c: Vector2, r: float, sf: float, cw: bool = true) -> void:
		center = c
		radius = r
		speed_factor = sf
		clockwise = cw

	func _tick(body: CharacterBody2D, delta: float) -> Vector2:
		var to_center := center - body.global_position
		var radial := to_center.normalized() * (to_center.length() - radius) * 3.0
		var tangent := Vector2(-to_center.normalized().y, to_center.normalized().x)
		if not clockwise:
			tangent = -tangent
		return (radial + tangent * speed_factor * 80.0)

class SequenceJob extends Job:
	var sequence: MovementSequence
	var step_index: int = 0
	var step_start_pos: Vector2
	var step_active: bool = false
	func _init(seq: MovementSequence, start_pos: Vector2) -> void:
		type = JobType.SEQUENCE
		sequence = seq;  step_start_pos = start_pos

# ── Settings ──────────────────────────────────────────────────────────────────
@export var default_walk_speed: float = 120.0
@export var default_dash_speed: float = 450.0
@export var default_arrival_radius: float = 24.0
@export var knockback_deceleration: float = 900.0
@export var push_deceleration: float = 1200.0

var _push_velocity: Vector2 = Vector2.ZERO

# ── Public state ──────────────────────────────────────────────────────────────
var facing_locked: bool = false

# ── Z-axis stub (for future jump/throw support) ───────────────────────────────
var z_height: float = 0.0
var z_velocity: float = 0.0

# ── Private ───────────────────────────────────────────────────────────────────
var _job: Job = Job.new()
var _body: CharacterBody2D
var _nav: NavigationAgent2D

# ── Setup ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_body = get_parent() as CharacterBody2D
	assert(_body != null, "MovementController must be a child of CharacterBody2D")
	_nav = _body.get_node_or_null("NavigationAgent2D") as NavigationAgent2D
	assert(_nav != null, "Unit requires a NavigationAgent2D child named 'NavigationAgent2D'")

func _physics_process(delta: float) -> void:
	match _job.type:
		JobType.KNOCKBACK:  _tick_knockback(delta)
		JobType.SEQUENCE:   _tick_sequence(delta)
		JobType.DASH:       _tick_dash()
		JobType.NAVIGATE:   _tick_navigate()
		JobType.REPOSITION: _tick_reposition(delta)
		_:
			_body.velocity = Vector2.ZERO
			_body.move_and_slide()
	
	if _push_velocity != Vector2.ZERO:
		_body.velocity = _push_velocity
		_body.move_and_slide()
		_push_velocity = _push_velocity.move_toward(Vector2.ZERO, push_deceleration * delta)

# ── Public API ────────────────────────────────────────────────────────────────

## Navigate to destination via pathfinding. Emits job_completed(NAVIGATE) on arrival.
func navigate_to(destination: Vector2, speed: float = -1.0, arrival_radius: float = -1.0) -> void:
	_try_set(NavigateJob.new(
		destination,
		speed if speed > 0.0 else default_walk_speed,
		arrival_radius if arrival_radius > 0.0 else default_arrival_radius))

## Dash directly to destination. Bypasses pathfinding. Stops at target or on terrain.
func dash_to(destination: Vector2, speed: float = -1.0, updates_facing: bool = true) -> void:
	_try_set(DashJob.new(
		destination,
		speed if speed > 0.0 else default_dash_speed,
		updates_facing))

## Apply knockback. Always overrides the current job.
func apply_knockback(direction: Vector2, force: float,
					 max_distance: float = INF, max_duration: float = INF) -> void:
	var j := KnockbackJob.new(
		direction.normalized() * force, knockback_deceleration, max_distance, max_duration)
	j.start_pos = _body.global_position
	_job = j  # no priority check — knockback always wins

## Perform a reposition.
func start_repositioning(center: Vector2, radius: float, speed_factor: float, clockwise: bool = true) -> void:
	_try_set(RepositionJob.new(center, radius, speed_factor, clockwise))

## Execute a scripted MovementSequence. Priority 4 — overrides nav/dash/reposition.
func execute_sequence(sequence: MovementSequence) -> void:
	_try_set(SequenceJob.new(sequence, _body.global_position))

## Cancel the current job. Knockback cannot be cancelled.
func cancel() -> void:
	if _job.type != JobType.KNOCKBACK:
		_job = Job.new()

func push(direction: Vector2, force: float) -> void:
	_push_velocity += direction.normalized() * force

# ── Queries ───────────────────────────────────────────────────────────────────
func is_knocked_back() -> bool:   return _job.type == JobType.KNOCKBACK
func is_in_sequence() -> bool:    return _job.type == JobType.SEQUENCE
func is_busy() -> bool:           return _job.type != JobType.NONE
func current_job() -> JobType:    return _job.type

# ── Tick implementations ──────────────────────────────────────────────────────

func _tick_navigate() -> void:
	var j := _job as NavigateJob
	_nav.target_position = j.destination
	if _nav.is_navigation_finished() \
	or _body.global_position.distance_to(j.destination) <= j.arrival_radius:
		_body.velocity = Vector2.ZERO
		_body.move_and_slide()
		_end_job(JobType.NAVIGATE)
		return
	var dir := _body.global_position.direction_to(_nav.get_next_path_position())
	_body.velocity = dir * j.speed
	_body.move_and_slide()
	_push_facing(dir)

func _tick_dash() -> void:
	var j := _job as DashJob
	var to_dest := j.destination - _body.global_position
	if to_dest.length() < 4.0:
		_body.velocity = Vector2.ZERO
		_body.move_and_slide()
		_end_job(JobType.DASH)
		return
	var dir := to_dest.normalized()
	_body.velocity = dir * j.speed
	_body.move_and_slide()
	if _body.get_slide_collision_count() > 0:
		_body.velocity = Vector2.ZERO
		_end_job(JobType.DASH)
		return
	if j.updates_facing:
		_push_facing(dir)

func _tick_knockback(delta: float) -> void:
	var j := _job as KnockbackJob
	j.elapsed += delta
	_body.velocity = j.velocity
	_body.move_and_slide()
	j.velocity = j.velocity.move_toward(Vector2.ZERO, j.deceleration * delta)
	var dist := _body.global_position.distance_to(j.start_pos)
	if j.velocity.length() < 5.0 or dist >= j.max_distance \
	or j.elapsed >= j.max_duration or _body.get_slide_collision_count() > 0:
		_body.velocity = Vector2.ZERO
		_body.move_and_slide()
		_job = Job.new()
		knocked_back_finished.emit()
		job_completed.emit()

func _tick_reposition(_delta: float) -> void:
	var j := _job as RepositionJob
	var to_center := j.center - _body.global_position
	var current_dist := to_center.length()
	# Radial: correct distance toward orbit radius
	var radial := to_center.normalized() * (current_dist - j.radius) * 3.0
	# Tangential: orbit direction
	var tangent := Vector2(-to_center.normalized().y, to_center.normalized().x)
	if not j.clockwise:
		tangent = -tangent
	var vel := (radial + tangent * j.speed_factor * 80.0)
	_body.velocity = vel.limit_length(default_walk_speed * j.speed_factor)
	_body.move_and_slide()
	_push_facing(vel.normalized())  # overridden by facing_override_position if set

func _tick_sequence(delta: float) -> void:
	var j := _job as SequenceJob
	if not j.step_active:
		if j.step_index >= j.sequence.steps.size():
			_end_job(JobType.SEQUENCE)
			sequence_completed.emit()
			return
		j.sequence.steps[j.step_index].begin(_body, j.step_start_pos)
		j.step_active = true
	var step: MovementStep = j.sequence.steps[j.step_index]
	if step.tick(delta, _body):
		sequence_step_completed.emit(j.step_index)
		j.step_index += 1
		j.step_start_pos = _body.global_position
		j.step_active = false

# ── Helpers ───────────────────────────────────────────────────────────────────
func _try_set(new_job: Job) -> void:
	if new_job.type >= _job.type:
		_job = new_job

func _end_job(_type: JobType) -> void:
	_job = Job.new()
	job_completed.emit()

func _push_facing(dir: Vector2) -> void:
	if facing_locked:
		return
	if dir != Vector2.ZERO:
		facing_updated.emit(dir)

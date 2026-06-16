extends Area2D
class_name Hitbox

signal target_hit(target: BaseUnit)

var hit_data: HitData = null
var hitbox_data: HitboxData = null
var already_hit: Array[Node] = []  # prevent multi-hit in same swing
var _time_since_last_check: float = INF
var _lifetime: float = 0.0

func setup(h_data: HitboxData, hit: HitData) -> void:
	hitbox_data = h_data
	hit_data = hit
	_apply_shape()
	# single frame check — use call_deferred so Area2D overlaps are populated
	_check_overlaps.call_deferred()

func _apply_shape() -> void:
	var shape_node := CollisionShape2D.new()
	match hitbox_data.shape:
		HitboxData.Shape.CIRCLE:
			var s := CircleShape2D.new()
			s.radius = hitbox_data.size.x
			shape_node.shape = s
		HitboxData.Shape.RECTANGLE:
			var s := RectangleShape2D.new()
			s.size = hitbox_data.size
			shape_node.shape = s
		HitboxData.Shape.CONE:
			var s := ConvexPolygonShape2D.new()
			var length : float = -hitbox_data.size.x
			var half_base := length * tan(deg_to_rad(hitbox_data.size.y / 2))
			s.points = [
				Vector2.ZERO,
				Vector2(length, half_base),
				Vector2(length, -half_base),
				]
			shape_node.shape = s
	shape_node.position = hitbox_data.offset
	add_child(shape_node)

func _physics_process(delta: float) -> void:
	_lifetime += delta
	
	if _lifetime >= hitbox_data.duration:
		queue_free()
		return
	
	
	_time_since_last_check += delta
	if _time_since_last_check >= hitbox_data.hit_check_interval:
		_time_since_last_check = 0.0
		_check_overlaps()

func _check_overlaps() -> void:
	for body in get_overlapping_areas():
		if body.is_in_group("Hurtbox") :
			_pass_checks(body.get_parent())  

func _pass_checks(body: BaseUnit) -> void:
	# multi hit check
	if not hitbox_data.multi_hit and already_hit.has(body):
		return
	# hitable check
	if not body.has_method("resolve_hit"):
		return
	# hit_owner check
	if hit_data.hit_owner != null and body == hit_data.hit_owner:
		return
	# team check
	if hit_data.hit_owner != null:
		var owner_unit := hit_data.hit_owner as BaseUnit
		if owner_unit and owner_unit.check_if_ally(body):
			return
	
	already_hit.append(body)
	# emit that the target was hit
	target_hit.emit(body)

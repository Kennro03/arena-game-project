extends Area2D
class_name Hurtbox

const SEPARATION_FORCE := 80.0
const MIN_DISTANCE := 24.0  

func body_knockback() -> void:
	push_units_from_body()
	
	_bounce_off_obstacles()

func push_units_from_body() -> void :
	for area in get_overlapping_areas():
		if not area.is_in_group("Hurtbox"):
			continue
		var other_unit := area.owner as BaseUnit
		if other_unit == null or other_unit == owner:
			continue
		
		var diff : Vector2 = owner.global_position - other_unit.global_position
		var dist : float = diff.length()
		
		if dist < 0.01:
			diff = Vector2(randf_range(-1, 1), randf_range(-1, 1))
			dist = diff.length()
		
		var overlap_ratio := clampf(1.0 - dist / MIN_DISTANCE, 0.0, 1.0)
		var force := SEPARATION_FORCE * (1.0 + overlap_ratio * 2.0)
		var direction := diff.normalized()
		
		owner.apply_knockback(other_unit, -direction, force)

func _bounce_off_obstacles() -> void:
	for body in get_overlapping_bodies():
		if not body is StaticBody2D:
			continue
		var diff : Vector2 = owner.global_position - body.global_position
		if diff.length() < 0.01:
			diff = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		
		var impact_speed : float = owner.knockback_velocity.length()
		owner.apply_knockback(owner, diff.normalized(), 200.0)
		
		# wall collision damage — only if moving fast into wall
		if impact_speed > 150.0:
			var impact_damage : float = (impact_speed - 150.0) * 0.1
			owner.take_damage(impact_damage)
			# signal for passive: "took wall collision damage"
			Events.wall_collision.emit(owner, impact_damage)

func get_overlapping_areas_in_area(areagroupname : String = "Hurtbox") -> Array:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(areagroupname):
			results.append(overlap)
	return results

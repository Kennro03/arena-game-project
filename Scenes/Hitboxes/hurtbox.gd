extends Area2D
class_name Hurtbox

const SEPARATION_FORCE := 80.0
const MIN_DISTANCE := 24.0  

func body_knockback() -> void:
	push_units_from_body()

func push_units_from_body() -> void:
	for area in get_overlapping_areas():
		if not area.is_in_group("Hurtbox"):
			continue
		var other_unit := area.get_parent() as HumanoidUnit
		if other_unit == null or other_unit == owner:
			continue

		var diff : Vector2 = owner.global_position - other_unit.global_position
		var dist : float = diff.length()
		if dist < 0.01:
			diff = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
			dist = diff.length()

		var overlap_ratio := clampf(1.0 - dist / MIN_DISTANCE, 0.0, 1.0)
		var force := SEPARATION_FORCE * (1.0 + overlap_ratio * 2.0)
		var direction := diff.normalized()

		# Push both units — soft additive, doesn't override movement jobs
		other_unit.movement_controller.push(-direction, force)
		(owner as HumanoidUnit).movement_controller.push(direction, force * 0.5)


func get_overlapping_areas_in_area(areagroupname : String = "Hurtbox") -> Array:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(areagroupname):
			results.append(overlap)
	return results

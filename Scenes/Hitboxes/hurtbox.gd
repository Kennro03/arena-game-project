extends Area2D
class_name Hurtbox

func body_knockback() -> void:
	for targetarea in %Hurtbox.get_overlapping_areas_in_area("Hurtbox") : 
		owner.apply_knockback(targetarea.owner, targetarea.owner.position - owner.position , 10.0)

func get_overlapping_areas_in_area(areagroupname : String = "Hurtbox") -> Array:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(areagroupname):
			results.append(overlap)
	return results

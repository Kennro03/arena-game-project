extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func stickman_body_knockback() -> void:
	for targetarea in %Hurtbox.get_overlapping_areas_in_area("Hurtbox") : 
		owner.apply_knockback(targetarea.owner, targetarea.owner.position - owner.position , 10.0)

func get_overlapping_areas_in_area(areagroupname : String = "Hurtbox") -> Array:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(areagroupname):
			results.append(overlap)
	return results

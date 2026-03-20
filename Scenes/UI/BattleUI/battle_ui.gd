extends Control

signal StartEncounterPressed()
signal introEnded

var selectedUnits : Array[BaseUnit] = []

@onready var animationPlayer := $AnimationPlayer

func _on_start_fight_button_pressed() -> void:
	StartEncounterPressed.emit()

func _on_begin_encounter() -> void:
	animationPlayer.play("hide_start_fight_button")
	await animationPlayer.animation_finished
	introEnded.emit()

func _input(event):
	return 
	if event is InputEventMouseButton and event.pressed :
		var space := get_viewport().world_2d.direct_space_state
		var query := PhysicsPointQueryParameters2D.new()
		query.position = get_viewport().get_mouse_position()
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var results := space.intersect_point(query)
		for result in results:
			#print("Hit area: ", result.collider.name)
			if result.collider.get_parent() is BaseUnit:
				var unit := result.collider.get_parent() as BaseUnit
				print("Clicked unit: ", unit.display_name)


func _on_lost_encounter() -> void:
	animationPlayer.play("LostAnimation")


func _on_won_encounter() -> void:
	animationPlayer.play("WinAnimation")

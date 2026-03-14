extends Control

signal StartEncounterPressed()
signal BeginFight
signal introEnded

@onready var animationPlayer := $AnimationPlayer

func _on_start_fight_button_pressed() -> void:
	StartEncounterPressed.emit()

func _on_begin_fight() -> void:
	animationPlayer.play("hide_start_fight_button")

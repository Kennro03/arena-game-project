extends Control
class_name BattleLostScreen

@onready var rich_text_label: RichTextLabel = %RichTextLabel

@onready var retry_button: Button = %RetryButton
@onready var continue_button: Button = %ContinueButton
@onready var give_up_button: Button = %GiveUpButton
@onready var quit_button: Button = %QuitButton

signal _retry       #Reset the battle, bringing units back to their state before the fight (should consider disabling this or limiting it in real game)
signal _continue    #Keep enemy and unit state, reseting combat phases and allowing player to deploy from reserve, blocked if no units in reserve
signal _give_up     #Signals defeat in battle, during expeditions, this signals the end/defeat of an expedition
signal _quit        #Exit the game, upon reloading, player is brought back to battle start

func _on_retry_button_pressed() -> void:
	_retry.emit()
	queue_free()

func _on_continue_button_pressed() -> void:
	_continue.emit()
	queue_free()

func _on_give_up_button_pressed() -> void:
	_give_up.emit()
	queue_free()

func _on_quit_button_pressed() -> void:
	_quit.emit()
	get_tree().quit() 

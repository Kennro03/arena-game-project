extends Control
class_name GoldDisplay

func _ready() -> void:
	update_display(Player.gold)
	Events.gold_changed.connect(update_display)

func update_display(new_value:int)->void:
	%GoldValueDisplay.text = str(new_value)

func _on_gain_gold_button_pressed() -> void:
	Player.gold += 10

func _on_lose_gold_button_pressed() -> void:
	Player.gold -= 10

extends EventEffect
class_name EventEffect_GainGold

@export var amount: int

func apply() -> void:
	Player.gold += amount

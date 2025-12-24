extends Resource
class_name StatScaling

@export var stat : Stats.BuffableStats
@export var scaling_value: float = 1.0
@export var scaling_power : float = 0.9

func _init(_stat: Stats.BuffableStats = Stats.BuffableStats.ATTUNEMENT, _scaling_value: float = 1.0, _scaling_power: float = 0.9) -> void:
	stat = _stat
	scaling_value = _scaling_value
	scaling_power = _scaling_power

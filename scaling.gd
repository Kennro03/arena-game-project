extends Resource
class_name StatScaling

enum ScalingType{
	LINEAR,
	PERCENT,
}

@export var stat : Stats.BuffableStats = Stats.BuffableStats.ATTUNEMENT
@export var scaling_value: float = 1.0
@export var scaling_type: ScalingType = ScalingType.LINEAR
@export var scaling_power : float = 0.9

func _init(_stat: Stats.BuffableStats = Stats.BuffableStats.ATTUNEMENT, _scaling_type : ScalingType = ScalingType.LINEAR, _scaling_value: float = 1.0, _scaling_power: float = 0.9) -> void:
	stat = _stat
	scaling_type = _scaling_type
	scaling_value = _scaling_value
	scaling_power = _scaling_power

func get_scaling_value() -> float :
	match scaling_type : 
		ScalingType.LINEAR : 
			return (pow(stat, scaling_power) * scaling_value)
		ScalingType.PERCENT :
			return 100.0 * (1.0 - exp(-stat * 0.01))
	printerr("Scaling Type not recognized!")
	return 0.0

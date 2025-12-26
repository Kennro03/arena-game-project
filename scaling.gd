extends Resource
class_name StatScaling

enum ScalingType{
	LINEAR,
	PERCENT,
}

@export var stat_value : float = 0.0
@export var scaling_value: float = 1.0
@export var scaling_type: ScalingType = ScalingType.LINEAR
@export var scaling_power : float = 0.9

func _init(_stat_value = 0.0, _scaling_type : ScalingType = ScalingType.LINEAR, _scaling_value: float = 1.0, _scaling_power: float = 0.9) -> void:
	stat_value = float(_stat_value)
	scaling_type = _scaling_type
	scaling_value = _scaling_value
	scaling_power = _scaling_power

func get_scaling_value() -> float :
	match scaling_type : 
		ScalingType.LINEAR : 
			var res : float = (pow(stat_value, scaling_power) * scaling_value)
			return res
		ScalingType.PERCENT :
			var res : float = 100.0 * (1.0 - exp(-stat_value * 0.01))
			return res
	printerr("Scaling Type not recognized!")
	return 0.0

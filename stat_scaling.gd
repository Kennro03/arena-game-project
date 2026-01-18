extends Resource
class_name StatScaling

enum ScalingType{
	LINEAR,
	PERCENT,
}

@export var source_stat : Stats.Attributes
@export var scaling_value: float = 1.0
@export var scaling_type: ScalingType = ScalingType.LINEAR
@export var scaling_power : float = 0.9

func _init(_source_stat : Stats.Attributes = Stats.Attributes.STRENGTH, _scaling_type : ScalingType = ScalingType.LINEAR, _scaling_value: float = 1.0, _scaling_power: float = 0.9) -> void:
	source_stat = _source_stat
	scaling_type = _scaling_type
	scaling_value = _scaling_value
	scaling_power = _scaling_power

func compute(stats : Stats) -> float :
	var stat_value := stats.get_current_attribute(source_stat)
	match scaling_type : 
		ScalingType.LINEAR : 
			var res : float = (pow(stat_value, scaling_power) * scaling_value)
			return res
		ScalingType.PERCENT :
			var _normalized_prob := 1.0 - exp(-stat_value * scaling_value * 0.01)
			var _res : float = 100.0 * (1.0 - exp(-stat_value * (scaling_value * 0.01)))
			return _normalized_prob
	printerr("Scaling Type not recognized!")
	return 0.0

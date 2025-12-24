extends Resource
class_name StatScaling

const scalingPower : float = 0.9
enum ScalingType {
	FLAT,
}

@export var stat : Stats.BuffableStats
@export var scaling_stat : Stats.BuffableStats
@export var scaling_value: float
@export var scaling_type : ScalingType

func _init(_stat: Stats.BuffableStats = Stats.BuffableStats.MAX_HEALTH, _scaling_value: float = 1.0, _scaling_type: StatScaling.ScalingType = ScalingType.FLAT) -> void:
	stat = _stat
	scaling_type = _scaling_type
	scaling_value = _scaling_value

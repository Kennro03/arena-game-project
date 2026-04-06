extends Resource
class_name StatBuff

enum BuffType {
	MULTIPLY,
	ADD,
}

@export var stat : Stats.BuffableStats
@export var buff_amount: float
@export var buff_type : BuffType

func _init(_stat: Stats.BuffableStats = Stats.BuffableStats.STRENGTH, 
			_buff_amount: float = 1.0,
			_buff_type: StatBuff.BuffType = BuffType.MULTIPLY) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount

static func random_flat_attribute_buff(min_amount: int = 1, max_amount: int = 15) -> StatBuff:
	var attribute : int = Stats.Attributes.values().pick_random()
	return StatBuff.new(
		Stats.BuffableStats.values()[attribute],
		randi_range(min_amount, max_amount),
		StatBuff.BuffType.ADD
	)

static func random_multiplier_stat_buff(min_amount: float = 0.1, max_amount: float = 0.3) -> StatBuff:
	return StatBuff.new(
		Stats.BuffableStats.values().pick_random(),
		randf_range(min_amount, max_amount),
		StatBuff.BuffType.MULTIPLY
	)

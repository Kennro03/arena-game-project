extends Resource
class_name WeaponStatBuff

enum BuffType {
	MULTIPLY,
	ADD,
}

@export var stat : Weapon.BuffableStats
@export var buff_amount: float
@export var buff_type : BuffType

func _init(_stat: Weapon.BuffableStats = Weapon.BuffableStats.DAMAGE, 
			_buff_amount: float = 1.0,
			_buff_type: WeaponStatBuff.BuffType = BuffType.MULTIPLY) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount

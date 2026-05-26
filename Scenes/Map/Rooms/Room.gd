extends Resource
class_name Room

enum Type { NOT_ASSIGNED, AMBUSH, SHOP, TREASURE, EVENT, CAMP, NORMAL_BATTLE, ELITE_BATTLE, BOSS_BATTLE }

@export var type: Type 
@export var row: int
@export var column: int
@export var position : Vector2
@export var next_rooms: Array[Room]
@export var selected := false

func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type][0]]

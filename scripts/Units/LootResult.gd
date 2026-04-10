extends RefCounted
class_name LootResult

var gold: int = 0
var items: Array[Item] = []

func merge(other: LootResult) -> void:
	gold += other.gold
	items.append_array(other.items)

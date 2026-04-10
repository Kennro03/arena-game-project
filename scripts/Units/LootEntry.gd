extends Resource
class_name LootEntry

@export var item: Item
@export var weight: float = 1.0
@export var drop_chance: float = 1.0  # 0..1, checked before weight roll

func try_drop() -> Item:
	if randf() > drop_chance:
		return null
	return item.duplicate(true)

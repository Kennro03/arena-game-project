extends Resource
class_name LootTable

@export var guaranteed_items: Array[Item] = []      # always dropped
@export var guaranteed_gold_min: int = 1
@export var guaranteed_gold_max: int = 6

@export var random_item_rolls: int = 0              # how many random item rolls
@export var item_pool: Array[LootEntry] = []        # weighted pool of possible items

@export var bonus_gold_min: int = 0                 # additional random gold
@export var bonus_gold_max: int = 0

func roll() -> LootResult:
	var result := LootResult.new()
	
	# guaranteed gold
	result.gold += randi_range(guaranteed_gold_min, guaranteed_gold_max)
	result.gold += randi_range(bonus_gold_min, bonus_gold_max)
	
	# guaranteed items
	for item in guaranteed_items:
		result.items.append(item.duplicate(true))
	
	# random item rolls
	for i in random_item_rolls:
		var rolled := _roll_item()
		if rolled:
			result.items.append(rolled)
	
	return result

func _roll_item() -> Item:
	if item_pool.is_empty():
		return null
	
	var total_weight : float = item_pool.reduce(func(acc, e): return acc + e.weight, 0.0)
	var _roll : float = randf_range(0.0, total_weight)
	
	for entry in item_pool:
		_roll -= entry.weight
		if _roll <= 0:
			return entry.item.duplicate(true) if entry.item else null
	
	return null

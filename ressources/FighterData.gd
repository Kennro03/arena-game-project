extends Resource
class_name FighterData

@export var arena_id: String = ""
@export var unit_data: UnitData = null

# stat distribution — null means fully random
@export var stat_archetype: StatArchetype = null

# ordered tag preferences for card draws — empty means fully random
@export var tag_priority: Array[String] = []

var wins: int = 0
var losses: int = 0
var draws: int = 0
var fights_count: int = 0

func get_win_rate() -> float:
	if fights_count == 0:
		return 0.0
	return float(wins) / float(fights_count)

func to_standings_dict() -> Dictionary:
	return {
		"id": arena_id,
		"name": unit_data.display_name if unit_data else "Unknown",
		"stats_archetype": StatArchetype,
		"tag_priority": tag_priority,
		"wins": wins,
		"losses": losses,
		"draws": draws,
		"fights": fights_count,
	}

func reset_fight_record() -> void:
	wins = 0
	losses = 0
	draws = 0
	fights_count = 0

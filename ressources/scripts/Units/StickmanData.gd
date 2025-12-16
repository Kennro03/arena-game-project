extends Resource
class_name StickmanData

## Identity / UI
@export var id: String = "stickman_default"
@export var display_name: String = "Stickman"
@export var description: String = ""
@export var icon: Texture2D
@export var color: Color = Color.from_hsv(randf(), 0.8, 0.9)
@export var team: Team = null

## Core Gameplay
@export var stats : Stats = Stats.new()
@export var skill_list : Array[Skill] = []
@export var weapon : Weapon

## Testing / variation metadata
@export var scale_multiplier: float = 1.0
@export var random_seed: int = 0
@export var tags: Array[String] = ["base","random"]   # e.g. ["test", "elite", "random"]
var multiplier_array : Array[float] = []

func duplicated() -> StickmanData:
	return duplicate(true)

func with_scale(multiplier: float) -> StickmanData:
	var data := duplicate(true)
	data.scale_multiplier = multiplier
	data.display_name = "%sx %.2f" % [display_name, multiplier]
	return data

func with_skills(skill_array: Array[Skill]) -> StickmanData:
	var data := duplicate(true)
	for s in skill_array:
		data.skill_list.append(s.duplicate(true))
	return data

func randomized(min_mul: float, max_mul: float, _seed := -1) -> StickmanData:
	var data := duplicate(true)
	if _seed >= 0:
		data.random_seed = _seed
		seed(_seed)
	var m := randf_range(min_mul, max_mul)
	data.scale_multiplier = m
	data.color = Color(randi()%255+1,randi()%255+1,randi()%255+1)
	data.display_name = "Random %.2f× %s" % [m, display_name]
	return data

func get_stats_dictionnary() -> Dictionary :
	return {
		"type": "Stickman",
		"speed": 100.0,
		"max_health": 100.0,
		"dodge_probability": 0.0,
		"parry_probability": 0.0,
		"block_probability": 0.0,
		"flat_block_power": 0.0,
		"percent_block_power": 0.0,
		
		"color": Color(255,255,255),
		"team": null,
		"skill_list": skill_list,
	}

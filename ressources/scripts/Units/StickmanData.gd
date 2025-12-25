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
@export var tags: Array[String] = ["base"]   # e.g. ["test", "elite", "random"]
var multiplier_array : Array[float] = []

func duplicated() -> StickmanData:
	return duplicate(true)

func with_stats(_stats : Stats) -> StickmanData:
	var data := duplicate(true)
	data.stats = _stats
	data.tags.append("custom_Stats")
	data.display_name = "%sx %.2f" % [display_name]
	return data

func with_scale(multiplier: float) -> StickmanData:
	var data := duplicate(true)
	data.scale_multiplier = multiplier
	
	data.stats.base_strength = stats.base_strength * scale_multiplier 
	data.stats.base_dexterity = stats.base_dexterity * scale_multiplier 
	data.stats.base_endurance = stats.base_endurance * scale_multiplier 
	data.stats.base_intellect = stats.base_intellect * scale_multiplier 
	data.stats.base_faith = stats.base_faith * scale_multiplier 
	data.stats.base_attunement = stats.base_attunement * scale_multiplier 
	
	data.tags.append("scaled")
	data.display_name = "%sx %.2f" % [display_name, multiplier]
	return data

func with_skills(skill_array: Array[Skill]) -> StickmanData:
	var data := duplicate(true)
	for s in skill_array:
		data.skill_list.append(s.duplicate(true))
	data.tags.append("skilled")
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
	data.tags.append("randomized")
	return data

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
	
	for prop in data.stats.get_property_list():
		if prop.name.begins_with("base_") and prop.type in [TYPE_FLOAT]:
			data.stats.set(prop.name, data.stats.get(prop.name) * multiplier)
	
	data.tags.append("scaled")
	data.display_name = "%sx %.2f" % [display_name, multiplier]
	return data

func with_skills(skill_array: Array[Skill]) -> StickmanData:
	var data := duplicate(true)
	for s in skill_array:
		data.skill_list.append(s.duplicate(true))
	data.tags.append("skilled")
	return data

enum RandomizationType {
	ADD,
	MULTIPLY,
}
func randomized(min_value: float, max_value: float,type : RandomizationType = RandomizationType.ADD, _seed := -1) -> StickmanData:
	var data := duplicate(true)
	if _seed >= 0:
		data.random_seed = _seed
		seed(_seed)
	match type : 
		RandomizationType.ADD : 
			for prop in data.stats.get_property_list():
				if prop.name.begins_with("base_") and prop.type in [TYPE_INT, TYPE_FLOAT]:
					var value := randf_range(min_value, max_value)
					data.stats.set(prop.name, data.stats.get(prop.name) + value)
		RandomizationType.MULTIPLY : 
			for prop in data.stats.get_property_list():
				if prop.name.begins_with("base_") and prop.type in [TYPE_INT, TYPE_FLOAT]:
					var value := randf_range(min_value, max_value)
					data.stats.set(prop.name, data.stats.get(prop.name) * value)
	
	data.display_name = "Random %s" % [display_name]
	data.tags.append("randomized")
	data.stats.recalculate_stats()
	#data.stats.print_attributes()
	return data

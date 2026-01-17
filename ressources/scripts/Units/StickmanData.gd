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
@export var weapon : Weapon = preload("res://ressources/Weapons/fists.tres").duplicate(true)

## Testing / variation metadata
@export var random_seed: int = 0
var multiplier_array : Array[float] = []

func duplicated() -> StickmanData:
	return duplicate(true)

func with_points(_stat_points : int) -> StickmanData:
	var data := duplicate(true)
	for i in range(_stat_points):
		var attr : String = Stats.Attributes.keys()[randi() % Stats.Attributes.size()]
		var prop : String = "base_" + attr.to_lower()
		data.stats.set(prop, data.stats.get(prop) + 1)
	data.display_name = "RandomPoints(%d) %s" % [_stat_points,display_name]
	return data

func with_weapon(_wep : Weapon) -> StickmanData:
	var data := duplicate(true)
	data.weapon = _wep
	data.display_name = "Armed(%s) %s" % [_wep.weaponName,display_name]
	return data

func with_stats(_stats : Stats) -> StickmanData:
	var data := duplicate(true)
	data.stats = _stats
	data.display_name = "CustomStats %s" % [display_name]
	return data

func with_scale(multiplier: float) -> StickmanData:
	var data := duplicate(true)
	
	for prop in data.stats.get_property_list():
		if prop.name.begins_with("base_") and prop.type in [TYPE_FLOAT]:
			data.stats.set(prop.name, data.stats.get(prop.name) * multiplier)
	
	data.display_name = "Scaled(%.2f) %s" % [multiplier, display_name]
	return data

func with_skills(skill_array: Array[Skill]) -> StickmanData:
	var data := duplicate(true)
	for s in skill_array:
		data.skill_list.append(s.duplicate(true))
	data.display_name = "Skilled %s" % [display_name]
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
	data.stats.recalculate_stats()
	#data.stats.print_attributes()
	return data

func with_onHit_weapon(status_effect : StatusEffect) -> StickmanData :
	var data := duplicate(true)
	
	data.weapon.onHitEffects.append(status_effect)
	
	data.display_name = "OnHit %s" % [status_effect]
	return data  

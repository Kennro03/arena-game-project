extends Resource
class_name StickmanData

## Identity / UI
@export var id: String = "stickman_default"
@export var display_name: String = "Stickman"
@export var show_name: bool = false
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
	data.display_name = "%s, RandomPoints(%d)" % [display_name, _stat_points]
	return data

func with_weapon(_wep : Weapon) -> StickmanData:
	var data := duplicate(true)
	data.weapon = _wep.duplicate(true)
	data.display_name = "%s, Armed(%s)" % [display_name, _wep.weaponName]
	return data

func with_stats(_stats : Stats) -> StickmanData:
	var data := duplicate(true)
	data.stats = _stats
	data.display_name = "%s, CustomStats" % [display_name]
	return data

func with_scale(multiplier: float) -> StickmanData:
	var data := duplicate(true)
	
	for prop in data.stats.get_property_list():
		if prop.name.begins_with("base_") and prop.type in [TYPE_FLOAT]:
			data.stats.set(prop.name, data.stats.get(prop.name) * multiplier)
	
	data.display_name = "%s, Scaled(%.2f)" % [display_name, multiplier]
	return data

func with_skills(skill_array: Array[Skill]) -> StickmanData:
	var data := duplicate(true)
	for s in skill_array:
		data.skill_list.append(s.duplicate(true))
	data.display_name = "%s, Skilled" % [display_name]
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
	
	data.display_name = "%s, Random" % [display_name]
	data.stats.recalculate_stats()
	#data.stats.print_attributes()
	return data

func with_onHit_passive_inflictStatusEffect(status_effect: StatusEffect) -> StickmanData:
	var data := duplicate(true)
	
	var passive := OnHitPassiveApplyStatusEffects.new()
	passive.setup([status_effect]) #error found, Cannot call method 'duplicate' on a null value.
	
	data.weapon.onHitPassives.append(passive)

	data.display_name = "%s, OnHit-%s" % [display_name, passive.onhit_passive_name]
	return data  

func with_onHit_passive(passive_effect : OnHitPassive) -> StickmanData :
	var data := duplicate(true)
	
	data.weapon.onHitPassives.append(passive_effect)
	
	data.display_name = "%s, OnHit-%s" % [display_name,passive_effect.onhit_passive_name]
	return data  

func with_random_modifiers(nb_modifiers : int = 1) -> StickmanData :
	var data := duplicate(true)
	while nb_modifiers >= 1 :
		var rand := randi() % 3 + 1
		match rand :
			1 :
				data = data.with_points(randi() % 100 + 1)
			2 : 
				if data.weapon.weaponName == "Unarmed" : 
					var temp : Array[OnHitPassive] = data.weapon.onHitPassives
					var weps : Array[Weapon] = []
					for file_name in DirAccess.get_files_at("res://ressources/Weapons/"):
						if (file_name.get_extension() == "tres") and (load("res://ressources/Weapons/"+file_name).weaponName != "Unarmed"):
							weps.append(load("res://ressources/Weapons/"+file_name))
					data = data.with_weapon(weps.pick_random())
					for effect in temp : 
						data = data.with_onHit_passive(effect)
				else :
					nb_modifiers += 1
			3 : 
				var effects : Array[StatusEffect] = []
				for file_name in DirAccess.get_files_at("res://ressources/Status_Effects/Statuses"):
					if (file_name.get_extension() == "tres"):
						effects.append(load("res://ressources/Status_Effects/Statuses/"+file_name))
				var random_attribute_status_debuff : StatusEffect = StatusEffect_Stat_Buff.new().setup(StatBuff.new(Stats.Attributes.values().pick_random(), -(randi() % 10 + 11), StatBuff.BuffType.ADD))
				print("randomly generated debuff : " + random_attribute_status_debuff.Status_effect_name)
				effects.append(random_attribute_status_debuff)
				data = data.with_onHit_passive_inflictStatusEffect(effects.pick_random())
			4 : 
				var passives : Array[OnHitPassive] = []
				for file_name in DirAccess.get_files_at("res://ressources/OnHit_Passives/"):
					if (file_name.get_extension() == "tres"):
						passives.append(load("res://ressources/OnHit_Passives/"+file_name))
				data = data.with_onHit_passive(passives.pick_random())
		nb_modifiers -= 1
	data.show_name = true
	return data

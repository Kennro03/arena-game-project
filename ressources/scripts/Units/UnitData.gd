extends Resource
class_name UnitData

var unit_scene : PackedScene = preload("res://Scenes/Units/BaseUnit/BaseUnit.tscn")

## Identity / UI
@export var id: String = "BaseUnit"
@export var display_name: String = "BaseUnit"
@export var description: String = "The template used to create units."

@export var icon: Texture2D
@export var color: Color = Color.from_hsv(randf(), 0.8, 0.9)
@export var show_name: bool = true
@export var show_health: bool = true
@export var team: Team = null

## Core Gameplay
@export var stats : Stats = Stats.new()
@export var skill_list : Array[Skill] = []
@export var weapon : Weapon = null
@export var default_weapon : Weapon = null

## Testing / variation metadata
@export var random_seed: int = 0
var multiplier_array : Array[float] = []

func _init() -> void:
	pass

func duplicated() -> UnitData:
	var copy := duplicate(true)
	copy.team = team  
	return copy

func with_points(_stat_points : int) -> UnitData:
	var data := duplicate(true)
	for i in range(_stat_points):
		var attr : String = Stats.Attributes.keys()[randi() % Stats.Attributes.size()]
		var prop : String = "base_" + attr.to_lower()
		data.stats.set(prop, data.stats.get(prop) + 1)
	data.display_name = "%s, RandomPoints(%d)" % [display_name, _stat_points]
	return data

func with_weapon(_wep : Weapon) -> UnitData:
	if _wep == null : 
		var weps : Array[Weapon] = []
		for file_name in DirAccess.get_files_at("res://ressources/Weapons/"):
			if (file_name.get_extension() == "tres") and (load("res://ressources/Weapons/"+file_name).weaponName != "Unarmed"):
				weps.append(load("res://ressources/Weapons/"+file_name))
		_wep = weps.pick_random()
	var data := duplicate(true)
	data.weapon = _wep.duplicate(true)
	data.display_name = "%s, Armed(%s)" % [display_name, _wep.weaponName]
	return data

func with_stats(_stats : Stats) -> UnitData:
	var data := duplicate(true)
	data.stats = _stats
	data.display_name = "%s, CustomStats" % [display_name]
	return data

func with_scale(multiplier: float) -> UnitData:
	var data := duplicate(true)
	
	for prop in data.stats.get_property_list():
		if prop.name.begins_with("base_") and prop.type in [TYPE_FLOAT]:
			data.stats.set(prop.name, data.stats.get(prop.name) * multiplier)
	
	data.display_name = "%s, Scaled(%.2f)" % [display_name, multiplier]
	return data

func with_skills(skill_array: Array[Skill]) -> UnitData:
	var data := duplicate(true)
	for s in skill_array:
		data.skill_list.append(s.duplicate(true))
	data.display_name = "%s, Skilled" % [display_name]
	return data

enum RandomizationType {
	ADD,
	MULTIPLY,
}
func randomized(min_value: float, max_value: float,type : RandomizationType = RandomizationType.ADD, _seed := -1) -> UnitData:
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

func with_onHit_passive(passive_effect: OnHitPassive) -> UnitData:
	var data := duplicate(true)
	if data.weapon :
		data.weapon.onHitPassives.append(passive_effect)
		data.display_name = "%s, OnHit-%s" % [display_name, passive_effect.onhit_passive_name]
	else : 
		printerr("No weapon to apply onHit passive to!")
	return data

# Helper to build an OnHitPassiveApplyStatusEffects cleanly
static func make_status_passive(
	effects: Array[StatusEffect],
	to_self: bool = false,
	chance: float = 1.0) -> OnHitPassiveApplyStatusEffects:
	var passive := OnHitPassiveApplyStatusEffects.new()
	passive.apply_to_self = to_self
	passive.apply_chance = chance
	passive.setup(effects)  # setup called AFTER flags set, so name generates correctly
	return passive

func with_random_modifiers(nb_modifiers : int = 1) -> UnitData :
	var data := duplicate(true)
	while nb_modifiers >= 1 :
		var rand := randi() % 6 + 1
		match rand :
			1 :
				# Give a random amount of points
				data = data.with_points(randi() % 80 + 1)
			2 : 
				# Give a random weapon if unarmed
				if data.weapon :
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
				else :
						nb_modifiers += 1
			3 : 
				# On-hit: inflict a random debuff (status effect or stat debuff) on enemy
				var effects : Array[StatusEffect] = []
				for file_name in DirAccess.get_files_at("res://ressources/Status_Effects/Statuses"):
					if (file_name.get_extension() == "tres"):
						effects.append(load("res://ressources/Status_Effects/Statuses/"+file_name))
				var random_attribute_status_debuff : StatusEffect = StatusEffect_Stat_Buff.new().setup(StatBuff.new(Stats.Attributes.values().pick_random(), -(randi() % 10 + 11), StatBuff.BuffType.ADD))
				#print("randomly generated debuff : " + random_attribute_status_debuff.Status_effect_name)
				effects.append(random_attribute_status_debuff)
				var picked : Array[StatusEffect] = [effects.pick_random()]
				var passive : OnHitPassiveApplyStatusEffects = data.make_status_passive(picked)
				
				data = data.with_onHit_passive(passive)
			4 : 
				# Add an on-hit passive (shield, chain to nearby target, ...)
				var passives : Array[OnHitPassive] = []
				for file_name in DirAccess.get_files_at("res://ressources/OnHit_Passives/"):
					if (file_name.get_extension() == "tres"):
						passives.append(load("res://ressources/OnHit_Passives/"+file_name))
				data = data.with_onHit_passive(passives.pick_random())
			5 :
				# On-hit: inflict a random weapon stat debuff on enemy
				var random_weapon_stat : Weapon.BuffableStats = Weapon.BuffableStats.values().pick_random()
				var debuff_amount : float = _random_weapon_stat_amount(random_weapon_stat, false)
				var weapon_stat_debuff : StatusEffect_WeaponStat_Buff = StatusEffect_WeaponStat_Buff.new().setup(
					WeaponStatBuff.new(random_weapon_stat, debuff_amount, WeaponStatBuff.BuffType.MULTIPLY))
				var effects : Array[StatusEffect] = [weapon_stat_debuff]
				var passive : OnHitPassiveApplyStatusEffects = data.make_status_passive(effects,false,0.75)
				data = data.with_onHit_passive(passive)
			6 :
				# On-hit: apply a random weapon stat buff to self
				var random_weapon_stat : Weapon.BuffableStats = Weapon.BuffableStats.values().pick_random()
				var buff_amount : float = _random_weapon_stat_amount(random_weapon_stat, true)
				var weapon_stat_self_buff : StatusEffect_WeaponStat_Buff = StatusEffect_WeaponStat_Buff.new().setup(
					WeaponStatBuff.new(random_weapon_stat, buff_amount, WeaponStatBuff.BuffType.MULTIPLY))
				var effects : Array[StatusEffect] = [weapon_stat_self_buff]
				var passive : OnHitPassiveApplyStatusEffects = data.make_status_passive(effects,true,0.75)
				data = data.with_onHit_passive(passive)
		nb_modifiers -= 1
	data.show_name = true
	return data

# Generates a sensible random multiplier per weapon stat
# buff = true means positive, false means debuff (values below 1.0 for MULTIPLY)
func _random_weapon_stat_amount(stat: Weapon.BuffableStats, buff: bool) -> float:
	var ranges : Dictionary = {
		Weapon.BuffableStats.DAMAGE:       [0.15, 0.20],
		Weapon.BuffableStats.ATTACK_SPEED: [0.10, 0.20],
		Weapon.BuffableStats.ATTACK_RANGE: [0.10, 0.15],
		Weapon.BuffableStats.KNOCKBACK:    [0.30, 0.50],
	}
	var r : Array = ranges.get(stat, [0.10, 0.30])
	var value : float = randf_range(r[0], r[1])
	# For MULTIPLY: buff adds to 1.0 (e.g. 1.25x), debuff subtracts (e.g. 0.75x)
	return 1.0 + value if buff else 1.0 - value

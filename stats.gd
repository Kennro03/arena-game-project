extends Resource
class_name Stats

const BASE_LEVEL_XP : float = 100.0
enum Attributes {
	STRENGTH,
	DEXTERITY,
	ENDURANCE,
	INTELLECT,
	FAITH,
	ATTUNEMENT,
}
static var attribute_icons : Dictionary = {
	Attributes.STRENGTH: preload("uid://dt0cp2f30m45t"),
	Attributes.DEXTERITY: preload("uid://cfyw7y21dyaf"),
	Attributes.ENDURANCE: preload("uid://jxl80ycljrt3"),
	Attributes.INTELLECT: preload("uid://rf3mtgwbnq6s"),
	Attributes.FAITH: preload("uid://c3uo37cadvvc8"),
	Attributes.ATTUNEMENT: preload("uid://rmmxh6vrcjbf"),
}

enum BuffableStats {
	STRENGTH,
	DEXTERITY,
	ENDURANCE,
	INTELLECT,
	FAITH,
	ATTUNEMENT,
	MAX_HEALTH,
	HEALTH_REGEN,
	MOVEMENT_SPEED,
	DODGE_PROBABILITY,
	PARRY_PROBABILITY,
	BLOCK_PROBABILITY,
	FLAT_BLOCK_POWER,
	PERCENT_BLOCK_POWER,
	CRIT_CHANCE,
	CRIT_DAMAGE,
	DAMAGE_TAKEN_BONUS,
	DAMAGE_TAKEN_MULTIPLIER,
	ACCESSORY_LIMIT,
}
static var stat_text_colors : Dictionary = {
	BuffableStats.STRENGTH: Color(0.91, 0.231, 0.231, 1.0),
	BuffableStats.DEXTERITY: Color(0.561, 0.827, 1.0, 1.0),
	BuffableStats.ENDURANCE: Color(0.569, 0.859, 0.412, 1.0),
	BuffableStats.INTELLECT: Color(0.565, 0.369, 0.663, 1.0),
	BuffableStats.FAITH: Color(0.976, 0.761, 0.169, 1.0),
	BuffableStats.ATTUNEMENT: Color(0.78, 0.863, 0.816, 1.0),
}
static var buffable_stat_icons : Dictionary = {
	# To be added later
}

signal health_depleted
signal health_changed(cur_health:float,max_health:float)
signal shield_depleted
signal shield_changed(cur_shield:float,max_shield:float)
signal stats_recalculated
signal exp_changed(old_exp:int,new_exp:int)
signal level_changed(new_level:int)

@export var base_strength : int = 0
@export var base_dexterity : int = 0
@export var base_endurance : int = 0
@export var base_intellect : int = 0
@export var base_faith : int = 0
@export var base_attunement : int = 0

@export var base_max_health : float = 100.0
@export var base_health_regen : float = 1.0
@export var base_movement_speed : float = 50.0
@export var base_dodge_probability : float = 10.0
@export var base_parry_probability : float = 5.0
@export var base_block_probability : float = 25.0
@export var base_flat_block_power : float = 0.0
@export var base_percent_block_power : float = 50.0
@export var base_crit_chance : float = 5.0
@export var base_crit_damage : float = 1.25
@export var base_damage_taken_bonus: float = 0.0
@export var base_damage_taken_multiplier: float = 1.0  
@export var base_accessory_limit : int = 1

@export var experience : int = 0: set = _on_experience_set

@export var max_health_scalings: Array[StatScaling] = [
	StatScaling.new(Attributes.ENDURANCE, StatScaling.ScalingType.LINEAR, 2.5),
	StatScaling.new(Attributes.ATTUNEMENT, StatScaling.ScalingType.LINEAR, 1.5)
]
@export var health_regen_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.ENDURANCE, StatScaling.ScalingType.LINEAR, 0.1),
	StatScaling.new(Attributes.FAITH, StatScaling.ScalingType.LINEAR, 0.08),
]
@export var movement_speed_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.DEXTERITY, StatScaling.ScalingType.LINEAR, 1.25, 0.9),
	StatScaling.new(Attributes.ATTUNEMENT, StatScaling.ScalingType.LINEAR, 0.75),
]
@export var dodge_probability_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.DEXTERITY, StatScaling.ScalingType.PERCENT, 0.6),
	StatScaling.new(Attributes.INTELLECT, StatScaling.ScalingType.PERCENT, 0.4),
]
@export var parry_probability_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.DEXTERITY, StatScaling.ScalingType.PERCENT, 0.2),
	StatScaling.new(Attributes.STRENGTH, StatScaling.ScalingType.PERCENT, 0.4),
	StatScaling.new(Attributes.INTELLECT, StatScaling.ScalingType.PERCENT, 0.4),
]
@export var block_probability_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.ENDURANCE, StatScaling.ScalingType.PERCENT, 0.6),
	StatScaling.new(Attributes.FAITH, StatScaling.ScalingType.PERCENT, 0.2),
]
@export var flat_block_power_scalings : Array[StatScaling]= [
	StatScaling.new(Attributes.ENDURANCE, StatScaling.ScalingType.LINEAR, 0.15),
]
@export var percent_block_power_scalings : Array[StatScaling]
@export var crit_chance_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.DEXTERITY, StatScaling.ScalingType.PERCENT, 0.3),
	StatScaling.new(Attributes.ATTUNEMENT, StatScaling.ScalingType.PERCENT, 0.25),
	StatScaling.new(Attributes.INTELLECT, StatScaling.ScalingType.PERCENT, 0.2),
]
@export var crit_damage_scalings : Array[StatScaling] = [
	StatScaling.new(Attributes.STRENGTH, StatScaling.ScalingType.LINEAR, 0.008),
	StatScaling.new(Attributes.ATTUNEMENT, StatScaling.ScalingType.LINEAR, 0.01),
]

var level : int : 
	get(): return floor(max(1.0, sqrt(experience / 100.0)+ 0.5))

var body : int 
var mind : int 

var current_strength : int 
var current_dexterity : int 
var current_endurance : int 
var current_intellect : int
var current_faith : int
var current_attunement : int

var current_max_health : float
var current_health_regen : float
var current_movement_speed : float
var current_dodge_probability : float 
var current_parry_probability : float 
var current_block_probability : float 
var current_flat_block_power : float 
var current_percent_block_power : float 
var current_crit_chance : float 
var current_crit_damage : float
var current_damage_taken_bonus : float
var current_damage_taken_multiplier : float
var current_accessory_limit : int

var dodge_prob_cap := 90.0
var block_prob_cap := 90.0
var parry_prob_cap := 90.0

var health : float = 0.0 : set = _on_health_set
var shield : float = 0.0 : set = _on_shield_set
var max_shield : float

var stat_buffs: Array[StatBuff]

func _init() -> void:
	setup_stats.call_deferred()

func setup_base_stats_from_dict(dict : Dictionary) -> void : 
	if dict.has("strength") :
		base_strength = dict["strength"] 
	if dict.has("dexterity") :
		base_dexterity = dict["dexterity"] 
	if dict.has("endurance") :
		base_endurance = dict["endurance"]  
	if dict.has("intellect") :
		base_intellect = dict["intellect"] 
	if dict.has("faith") :
		base_faith = dict["faith"] 
	if dict.has("attunement") :
		base_attunement = dict["attunement"] 
	if dict.has("max_health") :
		base_max_health = dict["max_health"] 
	if dict.has("health_regen") :
		base_health_regen = dict["health_regen"] 
	if dict.has("movement_speed") :
		base_movement_speed = dict["movement_speed"] 
	if dict.has("dodge_probability") :
		base_dodge_probability = dict["dodge_probability"] 
	if dict.has("parry_probability") :
		base_parry_probability = dict["parry_probability"] 
	if dict.has("block_probability") :
		base_block_probability = dict["block_probability"] 
	if dict.has("flat_block_power") :
		base_flat_block_power = dict["flat_block_power"] 
	if dict.has("percent_block_power") :
		base_percent_block_power = dict["percent_block_power"] 
	if dict.has("crit_chance") :
		base_crit_chance = dict["crit_chance"]  
	if dict.has("crit_damage") :
		base_crit_damage = dict["crit_damage"] 
	if dict.has("damage_taken_bonus") :
		base_damage_taken_bonus = dict["damage_taken_bonus"] 
	if dict.has("damage_taken_multiplier") :
		base_damage_taken_multiplier = dict["damage_taken_multiplier"] 
	if dict.has("accessory_limit") :
		base_accessory_limit = dict["accessory_limit"] 
	recalculate_stats()

func add_buff(buff: StatBuff) -> void :
	stat_buffs.append(buff)
	recalculate_stats()

func remove_buff(buff: StatBuff) -> void :
	stat_buffs.erase(buff)
	recalculate_stats()

func setup_stats() -> void :
	recalculate_stats() 
	health = current_max_health
	max_shield = current_max_health
	shield = 0.0

func recalculate_stats() -> void :
	reset_current_stats()
	var stat_multipliers: Dictionary = {} #Amount to multiply stats by
	var stat_addends: Dictionary = {} #Amount to add to included stats
	
	## Maybe apply scalings to base stats? 
	current_strength = int(base_strength )
	current_dexterity = int(base_dexterity)
	current_endurance = int(base_endurance)
	current_intellect = int(base_intellect)
	current_faith = int(base_faith)
	current_attunement = int(base_attunement)
	
	#Stat scaling logic
	for scaling in max_health_scalings : 
		current_max_health += scaling.compute(self)
	current_max_health = snapped(current_max_health,0.01)
	for scaling in health_regen_scalings : 
		current_health_regen += scaling.compute(self)
	current_health_regen = snapped(current_health_regen,0.01)
	for scaling in movement_speed_scalings : 
		current_movement_speed += scaling.compute(self)
	current_movement_speed = max(0.0,snapped(current_movement_speed,0.01))
	for scaling in flat_block_power_scalings : 
		current_flat_block_power += scaling.compute(self)
	current_flat_block_power = snapped(current_flat_block_power,0.01)
	for scaling in crit_chance_scalings : 
		current_crit_chance += scaling.compute(self)
	current_crit_chance = snapped(current_crit_chance,0.01)
	for scaling in crit_damage_scalings : 
		current_crit_damage += scaling.compute(self)
	current_crit_damage = snapped(current_crit_damage,0.01)
	
	var combined : float
	combined = 1.0
	for scaling in dodge_probability_scalings : 
		combined *= (1.0 - scaling.compute(self))
	current_dodge_probability = min(dodge_prob_cap,snapped(current_dodge_probability+(1.0 - combined) * 100.0,0.01)) 
	
	combined = 1.0
	for scaling in parry_probability_scalings : 
		combined *= (1.0 - scaling.compute(self))
	current_parry_probability = min(parry_prob_cap, snapped(current_parry_probability+(1.0 - combined) * 100.0,0.01)) 
	
	combined = 1.0
	
	for scaling in block_probability_scalings : 
		combined *= (1.0 - scaling.compute(self))
	current_block_probability = min(block_prob_cap, snapped(current_block_probability+(1.0 - combined) * 100.0,0.01)) 
	
	combined = 1.0
	for scaling in percent_block_power_scalings : 
		combined *= (1.0 - scaling.compute(self))
	current_percent_block_power = snapped(current_percent_block_power+(1.0 - combined) * 100.0,0.01) 
	
	
	for buff in stat_buffs :
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
		#print("Processing buff: stat=%s, amount=%s, type=%s" % [stat_name, buff.buff_amount, buff.buff_type])
		#var cur_property_name := "current_" + stat_name
		#print("Property exists: ", get(cur_property_name) != null)
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
			
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] += buff.buff_amount
				
				if stat_multipliers[stat_name] < 0.0:
					stat_multipliers[stat_name] = 0.0
	
	for stat_name in stat_multipliers:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	for stat_name in stat_addends:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
	
	body = current_strength + current_dexterity + current_endurance
	mind = current_intellect + current_faith + current_attunement
	stats_recalculated.emit()

func _on_health_set(new_value : float) -> void:
	health = clampf(new_value, 0, current_max_health)
	health_changed.emit(health,current_max_health)
	if health <=0:
		health_depleted.emit()

func _on_shield_set(new_value : float) -> void:
	shield = clampf(new_value, 0, max_shield)
	shield_changed.emit(shield,max_shield)
	if shield <=0:
		shield_depleted.emit()

func _on_experience_set(new_value : int) -> void :
	var old_level : int = level
	var old_exp : int = experience
	experience = new_value
	exp_changed.emit(old_exp,experience)
	if not old_level == level :
		level_changed.emit(level)
		recalculate_stats() 

func get_xp_for_level(target_level: int) -> int:
	return int(pow(max(0, target_level - 0.5), 2) * 100.0)

func get_level_progress() -> float:
	var xp_current_level := get_xp_for_level(level)
	var xp_next_level := get_xp_for_level(level + 1)
	return float(experience - xp_current_level) / float(xp_next_level - xp_current_level)

func get_xp_in_current_level() -> int:
	return experience - get_xp_for_level(level)

func get_xp_needed_for_next_level() -> int:
	return get_xp_for_level(level + 1) - get_xp_for_level(level)

enum StatValueType { BASE, CURRENT }
func get_stats_dictionary(value_type: StatValueType = StatValueType.BASE) -> Dictionary:
	match value_type :
		StatValueType.CURRENT :
			return {
			"strength": current_strength,
			"dexterity": current_dexterity,
			"endurance": current_endurance,
			"intellect": current_intellect,
			"faith": current_faith,
			"attunement": current_attunement,

			"max_health": current_max_health,
			"health_regen": current_health_regen,
			"movement_speed": current_movement_speed,
			"dodge_probability": current_dodge_probability,
			"parry_probability": current_parry_probability,
			"block_probability": current_block_probability,
			"flat_block_power": current_flat_block_power,
			"percent_block_power": current_percent_block_power,
			"crit_chance": current_crit_chance,
			"crit_damage": current_crit_damage,
			"damage_taken_bonus": current_damage_taken_bonus,
			"damage_taken_multiplier": current_damage_taken_multiplier,
			"accessory_limit": current_accessory_limit,

			"level": level,
			"health": health
		}
		StatValueType.BASE :
			return {
				"strength": base_strength,
				"dexterity": base_dexterity,
				"endurance": base_endurance,
				"intellect": base_intellect,
				"faith": base_faith,
				"attunement": base_attunement,

				"max_health": base_max_health,
				"health_regen": base_health_regen,
				"movement_speed": base_movement_speed,
				"dodge_probability": base_dodge_probability,
				"parry_probability": base_parry_probability,
				"block_probability": base_block_probability,
				"flat_block_power": base_flat_block_power,
				"percent_block_power": base_percent_block_power,
				"crit_chance": base_crit_chance,
				"crit_damage": base_crit_damage,
				"damage_taken_bonus": base_damage_taken_bonus,
				"damage_taken_multiplier": base_damage_taken_multiplier,
				"accessory_limit" : base_accessory_limit,

				"experience": experience,
			}
		_: 
			printerr("Value type not valid, use a correct StatValueType")
	return {}

func get_current_attribute(attr: Attributes) -> int:
	match attr:
		Attributes.STRENGTH: return current_strength
		Attributes.DEXTERITY: return current_dexterity
		Attributes.ENDURANCE: return current_endurance
		Attributes.INTELLECT: return current_intellect
		Attributes.FAITH: return current_faith
		Attributes.ATTUNEMENT: return current_attunement
	return 0

func get_current_stat(stat: BuffableStats) -> float:
	match stat:
		BuffableStats.STRENGTH: return current_strength
		BuffableStats.DEXTERITY: return current_dexterity
		BuffableStats.ENDURANCE: return current_endurance
		BuffableStats.INTELLECT: return current_intellect
		BuffableStats.FAITH: return current_faith
		BuffableStats.ATTUNEMENT: return current_attunement
		BuffableStats.MAX_HEALTH: return current_max_health
		BuffableStats.HEALTH_REGEN: return current_health_regen
		BuffableStats.MOVEMENT_SPEED: return current_movement_speed
		BuffableStats.DODGE_PROBABILITY: return current_dodge_probability
		BuffableStats.PARRY_PROBABILITY: return current_parry_probability
		BuffableStats.BLOCK_PROBABILITY: return current_block_probability
		BuffableStats.FLAT_BLOCK_POWER: return current_flat_block_power
		BuffableStats.PERCENT_BLOCK_POWER: return current_percent_block_power
		BuffableStats.CRIT_CHANCE: return current_crit_chance
		BuffableStats.CRIT_DAMAGE: return current_crit_damage
		BuffableStats.DAMAGE_TAKEN_BONUS: return current_damage_taken_bonus
		BuffableStats.DAMAGE_TAKEN_MULTIPLIER: return current_damage_taken_multiplier
		BuffableStats.ACCESSORY_LIMIT: return current_accessory_limit
	return 0

func print_attributes()-> void:
	print("Current Strength : " + str(current_strength))
	print("Current Dexterity : " + str(current_dexterity))
	print("Current Endurance : " + str(current_endurance))
	print("Current Intellect : " + str(current_intellect))
	print("Current Faith : " + str(current_faith))
	print("Current Attunement : " + str(current_attunement))

func print_stats()-> void :
	print("Current max health : " + str(current_max_health))
	print("Current health regen : " + str(current_health_regen))
	print("Current movement speed : " + str(current_movement_speed))
	print("Current dodge chance : " + str(current_dodge_probability))
	print("Current parry chance : " + str(current_parry_probability))
	print("Current block chance : " + str(current_block_probability))
	print("Current block (flat) power : " + str(current_flat_block_power))
	print("Current block (percent) power : " + str(current_percent_block_power))
	print("Current crit chance : " + str(current_crit_chance))
	print("Current crit damage : " + str(current_crit_damage))
	print("Current damage taken bonus : " + str(current_damage_taken_bonus))
	print("Current percent damage taken : " + str(current_damage_taken_multiplier))
	print("Current max number of accessories : " + str(current_accessory_limit))

func reset_current_stats() -> void:
	current_strength = base_strength
	current_dexterity = base_dexterity
	current_endurance = base_endurance
	current_intellect = base_intellect
	current_faith = base_faith
	current_attunement = base_attunement

	current_max_health = base_max_health
	current_health_regen = base_health_regen
	current_movement_speed = base_movement_speed
	current_dodge_probability = base_dodge_probability
	current_parry_probability = base_parry_probability
	current_block_probability = base_block_probability
	current_flat_block_power = base_flat_block_power
	current_percent_block_power = base_percent_block_power
	current_crit_chance = base_crit_chance
	current_crit_damage = base_crit_damage
	current_damage_taken_bonus = base_damage_taken_bonus
	current_damage_taken_multiplier = base_damage_taken_multiplier
	current_accessory_limit = base_accessory_limit

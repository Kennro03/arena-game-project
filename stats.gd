extends Resource
class_name Stats

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
	PERCENT_BLOCK_POWER
}

const STAT_CURVES: Dictionary[BuffableStats, Curve] = {
	BuffableStats.STRENGTH: preload("uid://dov560ppbcvrd"),
	BuffableStats.DEXTERITY: preload("uid://dov560ppbcvrd"),
	BuffableStats.ENDURANCE: preload("uid://dov560ppbcvrd"),
	BuffableStats.INTELLECT: preload("uid://dov560ppbcvrd"),
	BuffableStats.FAITH: preload("uid://dov560ppbcvrd"),
	BuffableStats.ATTUNEMENT: preload("uid://dov560ppbcvrd"),
	BuffableStats.MAX_HEALTH: preload("uid://dov560ppbcvrd"),
	BuffableStats.HEALTH_REGEN: preload("uid://dov560ppbcvrd"),
	BuffableStats.MOVEMENT_SPEED: preload("uid://dov560ppbcvrd"),
	BuffableStats.DODGE_PROBABILITY: preload("uid://dov560ppbcvrd"),
	BuffableStats.PARRY_PROBABILITY: preload("uid://dov560ppbcvrd"),
	BuffableStats.BLOCK_PROBABILITY: preload("uid://dov560ppbcvrd"),
	BuffableStats.FLAT_BLOCK_POWER: preload("uid://dov560ppbcvrd"),
	BuffableStats.PERCENT_BLOCK_POWER: preload("uid://dov560ppbcvrd")
	
}

const BASE_LEVEL_XP : float = 100.0

signal health_depleted
signal health_changed(cur_health:float,max_health:float)



@export var base_strength : int = 0
@export var base_dexterity : int = 0
@export var base_endurance : int = 0
@export var base_intellect : int = 0
@export var base_faith : int = 0
@export var base_attunement : int = 0

@export var base_max_health : float = 100.0
@export var base_health_regen : float = 2.0
@export var base_movement_speed : float = 100.0
@export var base_dodge_probability : float = 10.0
@export var base_parry_probability : float = 5.0
@export var base_block_probability : float = 40.0
@export var base_flat_block_power : float = 0.0
@export var base_percent_block_power : float = 50.0

@export var experience : int = 0: set = _on_experience_set

var level : int : 
	get(): return floor(max(1.0, sqrt(experience / 100.0)+ 0.5))

var current_strength : int = 0
var current_dexterity : int = 0
var current_endurance : int = 0
var current_intellect : int = 0
var current_faith : int = 0
var current_attunement : int = 0

var current_max_health : float = 100.0
var current_health_regen : float = 2.0
var current_movement_speed : float = 100.0
var current_dodge_probability : float = 10.0
var current_parry_probability : float = 5.0
var current_block_probability : float = 40.0
var current_flat_block_power : float = 0.0
var current_percent_block_power : float = 50.0

var health : float = 0.0 : set = _on_health_set

var stat_buffs: Array[StatBuff]

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats() -> void :
	recalculate_stats() 
	health = current_max_health

func add_buff(buff: StatBuff) -> void :
	stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_buff(buff: StatBuff) -> void :
	stat_buffs.erase(buff)
	recalculate_stats.call_deferred()

func recalculate_stats() -> void :
	var stat_multipliers: Dictionary = {} #Amount to multiply stats by
	var stat_addends: Dictionary = {} #Amount to add to included stats
	for buff in stat_buffs :
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
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
	
	
	var stat_sample_pos: float = (float(level) / 100.0) - 0.01
	current_strength = int(base_strength * STAT_CURVES[BuffableStats.STRENGTH].sample(stat_sample_pos))
	current_dexterity = int(base_dexterity * STAT_CURVES[BuffableStats.DEXTERITY].sample(stat_sample_pos))
	current_endurance = int(base_endurance * STAT_CURVES[BuffableStats.ENDURANCE].sample(stat_sample_pos))
	current_intellect = int(base_intellect * STAT_CURVES[BuffableStats.INTELLECT].sample(stat_sample_pos))
	current_faith = int(base_faith * STAT_CURVES[BuffableStats.FAITH].sample(stat_sample_pos))
	current_attunement = int(base_attunement * STAT_CURVES[BuffableStats.ATTUNEMENT].sample(stat_sample_pos))
	current_max_health = base_max_health * STAT_CURVES[BuffableStats.MAX_HEALTH].sample(stat_sample_pos)
	current_health_regen = base_health_regen * STAT_CURVES[BuffableStats.HEALTH_REGEN].sample(stat_sample_pos)
	current_movement_speed = base_movement_speed * STAT_CURVES[BuffableStats.MOVEMENT_SPEED].sample(stat_sample_pos)
	current_dodge_probability = base_dodge_probability * STAT_CURVES[BuffableStats.DODGE_PROBABILITY].sample(stat_sample_pos)
	current_parry_probability = base_parry_probability * STAT_CURVES[BuffableStats.PARRY_PROBABILITY].sample(stat_sample_pos)
	current_block_probability = base_block_probability * STAT_CURVES[BuffableStats.BLOCK_PROBABILITY].sample(stat_sample_pos)
	current_flat_block_power = base_flat_block_power * STAT_CURVES[BuffableStats.FLAT_BLOCK_POWER].sample(stat_sample_pos)
	current_percent_block_power = base_percent_block_power * STAT_CURVES[BuffableStats.PERCENT_BLOCK_POWER].sample(stat_sample_pos)
	
	for stat_name in stat_multipliers:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	for stat_name in stat_addends:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])


func _on_health_set(new_value : float) -> void:
	health = clampf(new_value, 0, current_max_health)
	health_changed.emit(health,current_max_health)
	if health <=0:
		health_depleted.emit()

func _on_experience_set(new_value : int) -> void :
	var old_level : int = level
	experience = new_value
	
	if not old_level == level :
		recalculate_stats() 

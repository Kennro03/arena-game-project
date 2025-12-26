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
	CRIT_DAMAGE
}

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
@export var base_crit_chance : float = 5.0
@export var base_crit_damage : float = 1.5
@export var experience : int = 0: set = _on_experience_set

@export var max_health_scalings: Array[StatScaling] = [
	StatScaling.new(current_endurance, StatScaling.ScalingType.LINEAR, 2.5),
	StatScaling.new(current_attunement, StatScaling.ScalingType.LINEAR, 1.5)
]
@export var health_regen_scalings : Array[StatScaling] = [
	StatScaling.new(current_endurance, StatScaling.ScalingType.LINEAR, 0.15),
	StatScaling.new(current_faith, StatScaling.ScalingType.LINEAR, 0.1)
]
@export var movement_speed_scalings : Array[StatScaling] = [
	StatScaling.new(current_dexterity, StatScaling.ScalingType.LINEAR, 5.0, 0.95),
]
@export var dodge_probability_scalings : Array[StatScaling] = [
	StatScaling.new(current_dexterity, StatScaling.ScalingType.PERCENT, 0.6),
	StatScaling.new(current_intellect, StatScaling.ScalingType.PERCENT, 0.4),
]
@export var parry_probability_scalings : Array[StatScaling] = [
	StatScaling.new(current_dexterity, StatScaling.ScalingType.PERCENT, 0.5),
	StatScaling.new(current_strength, StatScaling.ScalingType.PERCENT, 0.25),
]
@export var block_probability_scalings : Array[StatScaling] = [
	StatScaling.new(current_endurance, StatScaling.ScalingType.PERCENT, 0.7),
	StatScaling.new(current_dexterity, StatScaling.ScalingType.PERCENT, 0.4),
]
@export var flat_block_power_scalings : Array[StatScaling]
@export var percent_block_power_scalings : Array[StatScaling]
@export var crit_chance_scalings : Array[StatScaling] = [
	StatScaling.new(current_dexterity, StatScaling.ScalingType.PERCENT, 0.4),
	StatScaling.new(current_attunement, StatScaling.ScalingType.PERCENT, 0.3),
	StatScaling.new(current_intellect, StatScaling.ScalingType.PERCENT, 0.2),
]
@export var crit_damage_scalings : Array[StatScaling] = [
	StatScaling.new(current_dexterity, StatScaling.ScalingType.PERCENT, 0.4),
	StatScaling.new(current_attunement, StatScaling.ScalingType.PERCENT, 0.3),
]

var level : int : 
	get(): return floor(max(1.0, sqrt(experience / 100.0)+ 0.5))

var body : int = 0
var mind : int = 0
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
var current_crit_chance : float = 5.0
var current_crit_damage : float = 1.5

var health : float = 0.0 : set = _on_health_set

var stat_buffs: Array[StatBuff]

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats() -> void :
	recalculate_stats() 
	health = current_max_health

func setup_base_stats_from_dict(dict : Dictionary) -> void : 
	base_strength = dict.get("strength",base_strength)
	base_dexterity = dict.get("dexterity",base_dexterity)
	base_endurance = dict.get("endurance",base_endurance)
	base_intellect = dict.get("intellect",base_intellect)
	base_faith = dict.get("faith",base_faith)
	base_attunement = dict.get("attunement",base_attunement)
	base_max_health = dict.get("max_health",base_max_health)
	base_health_regen = dict.get("health_regen",base_health_regen)
	base_movement_speed = dict.get("movement_speed",base_movement_speed)
	base_dodge_probability = dict.get("dodge_probability",base_dodge_probability)
	base_parry_probability = dict.get("parry_probability",base_parry_probability)
	base_block_probability = dict.get("block_probability",base_block_probability)
	base_flat_block_power = dict.get("flat_block_power",base_flat_block_power)
	base_percent_block_power = dict.get("percent_block_power",base_percent_block_power)
	base_crit_chance = dict.get("crit_chance",base_crit_chance)
	base_crit_damage = dict.get("crit_damage",base_crit_damage)

func add_buff(buff: StatBuff) -> void :
	stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_buff(buff: StatBuff) -> void :
	stat_buffs.erase(buff)
	recalculate_stats.call_deferred()

func recalculate_stats() -> void :
	var stat_multipliers: Dictionary = {} #Amount to multiply stats by
	var stat_addends: Dictionary = {} #Amount to add to included stats
	
	#Stat scaling logic will be calculated here, for each buffable stat, every scaling will be applied depending on its scaling stat and the current stat value
	for scaling in max_health_scalings : 
		current_max_health += scaling.get_scaling_value()
	for scaling in health_regen_scalings : 
		current_health_regen += scaling.get_scaling_value()
	for scaling in movement_speed_scalings : 
		current_movement_speed += scaling.get_scaling_value()
	for scaling in dodge_probability_scalings : 
		current_dodge_probability += scaling.get_scaling_value()
	for scaling in parry_probability_scalings : 
		current_parry_probability += scaling.get_scaling_value()
	for scaling in block_probability_scalings : 
		current_block_probability += scaling.get_scaling_value()
	for scaling in flat_block_power_scalings : 
		current_flat_block_power += scaling.get_scaling_value()
	for scaling in percent_block_power_scalings : 
		current_percent_block_power += scaling.get_scaling_value()
	for scaling in crit_chance_scalings : 
		current_crit_chance += scaling.get_scaling_value()
	for scaling in crit_damage_scalings : 
		current_crit_damage += scaling.get_scaling_value()
	
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
	
	var _stat_sample_pos: float = (float(level) / 100.0) - 0.01
	body = current_strength + current_dexterity + current_endurance
	mind = current_intellect + current_faith + current_attunement
	
	## Maybe apply scalings to base stats? 
	current_strength = int(base_strength )
	current_dexterity = int(base_dexterity)
	current_endurance = int(base_endurance)
	current_intellect = int(base_intellect)
	current_faith = int(base_faith)
	current_attunement = int(base_attunement)
	
	for stat_name in stat_multipliers:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	for stat_name in stat_addends:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])


func apply_scale(multiplier: float) -> void:
	if multiplier == 1.0:
		return

	for stat in BuffableStats.values():
		if stat in [
			BuffableStats.STRENGTH,
			BuffableStats.DEXTERITY,
			BuffableStats.ENDURANCE,
			BuffableStats.INTELLECT,
			BuffableStats.FAITH,
			BuffableStats.ATTUNEMENT,
			
			BuffableStats.MAX_HEALTH,
			BuffableStats.HEALTH_REGEN,
			BuffableStats.MOVEMENT_SPEED,
			BuffableStats.DODGE_PROBABILITY,
			BuffableStats.PARRY_PROBABILITY,
			BuffableStats.BLOCK_PROBABILITY,
			BuffableStats.FLAT_BLOCK_POWER,
			BuffableStats.PERCENT_BLOCK_POWER,
			BuffableStats.CRIT_CHANCE,
			BuffableStats.CRIT_DAMAGE,
		]:
			add_buff(
				StatBuff.new(
					stat,
					multiplier - 1.0,
					StatBuff.BuffType.MULTIPLY
				)
			)

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


enum StatValueType { BASE, CURRENT }
func get_stats_dictionary(value_type: StatValueType = StatValueType.BASE) -> Dictionary:
	if value_type == StatValueType.BASE : 
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

			"level": level,
			"health": health
		}
	else : 
		printerr("Value type not valid, use a correct StatValueType")
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

			"level": level,
			"health": health
		}

func print_attributes()-> void:
	print("Base Strength : " + str(base_strength))
	print("Base Dexterity : " + str(base_dexterity))
	print("Base Endurance : " + str(base_endurance))
	print("Base Intellect : " + str(base_intellect))
	print("Base Faith : " + str(base_faith))
	print("Base Attunement : " + str(base_attunement))
	
	print("Current Strength : " + str(current_strength))
	print("Current Dexterity : " + str(current_dexterity))
	print("Current Endurance : " + str(current_endurance))
	print("Current Intellect : " + str(current_intellect))
	print("Current Faith : " + str(current_faith))
	print("Current Attunement : " + str(current_attunement))

extends Resource
class_name StickmanData

@export var type = "Default Stickman"
@export var icon: Texture2D
@export var description: String = ""

@export var speed: float = 100.0
@export var max_health: float = 100.0
var health: float = max_health
@export var health_regen: float = 2.0
@export var damage: float = 20.0
@export var attack_speed: float = 1.0
@export var aggro_range: float = 500.0
@export var attack_range: float = 50.0
@export var knockback: float = 100.0

@export var dodge_probability := 5.0
@export var parry_probability := 5.0
@export var block_probability := 10.0
@export var flat_block_power := 1.0
@export var percent_block_power := 50.0

@export var color := Color()

@export var skill_list : Array[Skill] = []

var multiplier_array : Array[float] = []

func get_skilled_stickmanData(multiplier: float = 0.0, skill_array : Array[Skill] = []) -> StickmanData : 
	var skill_stickman_data = StickmanData.new()
	skill_stickman_data.type= "Skilled Stickman"
	skill_stickman_data.speed= round(speed * multiplier * 100) / 100.0
	skill_stickman_data.max_health= round(max_health * multiplier * 100) / 100.0
	skill_stickman_data.damage= round(damage * multiplier * 100) / 100.0
	skill_stickman_data.attack_speed= round(attack_speed * multiplier * 100) / 100.0
	skill_stickman_data.aggro_range= round(aggro_range * multiplier * 100) / 100.0
	skill_stickman_data.attack_range= round(attack_range * multiplier * 100) / 100.0
	skill_stickman_data.knockback= round(knockback * multiplier * 100) / 100.0
	
	skill_stickman_data.dodge_probability= round(dodge_probability * multiplier * 100) / 100.0
	skill_stickman_data.parry_probability= round(parry_probability * multiplier * 100) / 100.0
	skill_stickman_data.block_probability= round(block_probability * multiplier * 100) / 100.0
	skill_stickman_data.flat_block_power= round(flat_block_power * multiplier * 100) / 100.0
	skill_stickman_data.percent_block_power= percent_block_power
	skill_stickman_data.color= Color(randf(),randf(),randf())
	
	skill_stickman_data.skill_list = skill_array
	return skill_stickman_data

func get_scaled_stickmanData(multiplier: float) -> StickmanData:
	var scaled_stickman_data = StickmanData.new()
	scaled_stickman_data.type= "Scaled "+str(multiplier)+" Stickman"
	scaled_stickman_data.speed= round(speed * multiplier * 100) / 100.0
	scaled_stickman_data.max_health= round(max_health * multiplier * 100) / 100.0
	scaled_stickman_data.damage= round(damage * multiplier * 100) / 100.0
	scaled_stickman_data.attack_speed= round(attack_speed * multiplier * 100) / 100.0
	scaled_stickman_data.aggro_range= round(aggro_range * multiplier * 100) / 100.0
	scaled_stickman_data.attack_range= round(attack_range * multiplier * 100) / 100.0
	scaled_stickman_data.knockback= round(knockback * multiplier * 100) / 100.0
	
	scaled_stickman_data.dodge_probability= round(dodge_probability * multiplier * 100) / 100.0
	scaled_stickman_data.parry_probability= round(parry_probability * multiplier * 100) / 100.0
	scaled_stickman_data.block_probability= round(block_probability * multiplier * 100) / 100.0
	scaled_stickman_data.flat_block_power= round(flat_block_power * multiplier * 100) / 100.0
	scaled_stickman_data.percent_block_power= percent_block_power
	scaled_stickman_data.color= Color(randf(),randf(),randf())
	return scaled_stickman_data

func get_randomized_stickmanData(rand_min_multiplier: float,rand_max_multiplier: float) -> StickmanData:
	var randomized_stickman_data = StickmanData.new()
	multiplier_array = []
	
	randomized_stickman_data.speed= randomize_stat(speed,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.max_health= randomize_stat(max_health,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.damage= randomize_stat(damage,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.attack_speed= randomize_stat(attack_speed,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.aggro_range= randomize_stat(aggro_range,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.attack_range= randomize_stat(attack_range,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.knockback= randomize_stat(knockback,rand_min_multiplier,rand_max_multiplier)
	
	randomized_stickman_data.dodge_probability= randomize_stat(dodge_probability,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.parry_probability= randomize_stat(parry_probability,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.block_probability= randomize_stat(block_probability,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.flat_block_power= randomize_stat(flat_block_power,rand_min_multiplier,rand_max_multiplier)
	randomized_stickman_data.percent_block_power= percent_block_power
	randomized_stickman_data.color= Color(randf(),randf(),randf())
	
	randomized_stickman_data.type= "Randomized "+str(rand_min_multiplier)+"-"+str(rand_max_multiplier)+" Stickman (avg=" + str(round(sum_array(multiplier_array)/multiplier_array.size()* 100) / 100.0 )+")"
	
	return randomized_stickman_data

func get_scaled_stats_dictionary(multiplier: float) -> Dictionary:
	return {
		"type": "Scaled "+str(multiplier)+" Stickman",
		"speed": speed * multiplier,
		"max_health": max_health * multiplier,
		"damage": damage * multiplier,
		"attack_speed": attack_speed * multiplier,
		"aggro_range": aggro_range,
		"attack_range": attack_range * multiplier,
		"knockback": knockback * multiplier,
		
		"dodge_probability": dodge_probability * multiplier,
		"parry_probability": parry_probability * multiplier,
		"block_probability": block_probability * multiplier,
		"flat_block_power": flat_block_power * multiplier,
		"percent_block_power": percent_block_power,
		"color": Color(randf(),randf(),randf()),
	}

func get_randomized_stats_dictionary(rand_min_multiplier: float,rand_max_multiplier: float) -> Dictionary:
	return {
		"type": "Randomized "+str(rand_min_multiplier)+"-"+str(rand_max_multiplier)+" Stickman",
		
		"speed": randf_range((speed*rand_min_multiplier),(speed*rand_max_multiplier)),
		"max_health": randf_range((max_health*rand_min_multiplier),(max_health*rand_max_multiplier)),
		"health_regen": randf_range((health_regen*rand_min_multiplier),(health_regen*rand_max_multiplier)),
		"damage": randf_range((damage*rand_min_multiplier),(damage*rand_max_multiplier)),
		"attack_speed": randf_range((attack_speed*rand_min_multiplier),(attack_speed*rand_max_multiplier)),
		"aggro_range": randf_range((aggro_range*rand_min_multiplier),(aggro_range*rand_max_multiplier)),
		"attack_range": randf_range((attack_range*rand_min_multiplier),(attack_range*rand_max_multiplier)),
		"knockback": randf_range((knockback*rand_min_multiplier),(knockback*rand_max_multiplier)),
		"dodge_probability": dodge_probability + 1 * randf_range((rand_min_multiplier),(rand_max_multiplier)),
		"parry_probability": parry_probability + 1 * randf_range((rand_min_multiplier),(rand_max_multiplier)),
		"block_probability": block_probability + 1 * randf_range((rand_min_multiplier),(rand_max_multiplier)),
		"flat_block_power": flat_block_power + 1 * randf_range((rand_min_multiplier),(rand_max_multiplier)),
		"percent_block_power": percent_block_power,
		"color": Color(randf(),randf(),randf()),
	}	

func randomize_stat(stat,min_rand : float,max_rand : float) -> float:
	var randomized_num : float = randf_range((min_rand),(max_rand))  
	var randomized_stat = round((int(stat)*randomized_num) * 100) / 100.0
	multiplier_array.append(randomized_num)
	return randomized_stat



static func sum_array(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum

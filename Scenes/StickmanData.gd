extends Resource
class_name StickmanData

@export var type = "Default Stickman"
@export var icon: Texture2D
@export var description: String = ""

@export var speed: float = 100.0
@export var health: float = 100.0
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

func get_scaled_stats(multiplier: float) -> Dictionary:
	return {
		"type": "Scaled "+str(multiplier)+" Stickman",
		"speed": speed * multiplier,
		"health": health * multiplier,
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

func get_randomized_stats(rand_min_multiplier: float,rand_max_multiplier: float) -> Dictionary:
	return {
		"type": "Randomized "+str(rand_min_multiplier)+"-"+str(rand_max_multiplier)+" Stickman",
		
		"speed": randf_range((speed*rand_min_multiplier),(speed*rand_max_multiplier)),
		"health": randf_range((health*rand_min_multiplier),(health*rand_max_multiplier)),
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

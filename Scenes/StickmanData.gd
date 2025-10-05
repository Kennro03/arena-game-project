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

@export var dodge_probability := 0.0
@export var parry_probability := 0.0
@export var block_probability := 0.0
@export var flat_block_power := 0.0
@export var percent_block_power := 50.0


func get_scaled_stats(multiplier: float) -> Dictionary:
	return {
		"speed": speed * multiplier,
		"health": health * multiplier,
		"damage": damage * multiplier,
		"attack_speed": attack_speed * multiplier,
		"aggro_range": aggro_range,
		"attack_range": attack_range * multiplier,
		"knockback": knockback * multiplier,
		"dodge_probability": dodge_probability + 10 * (multiplier-1),
		"parry_probability": parry_probability + 10 * (multiplier-1),
		"block_probability": block_probability + 50 * (multiplier-1),
		"flat_block_power": flat_block_power + 10 * (multiplier-1),
		"percent_block_power": percent_block_power,
	}

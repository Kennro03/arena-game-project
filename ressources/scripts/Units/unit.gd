extends Resource
class_name Unit

@export var type = "Default Stickman"
@export var icon: Texture2D
@export var description: String = ""
@export var team : Team
@export var sprite_color := Color(255.0,255.0,255.0)

@export var speed := 100.0:
	set(value):
		speed = clamp(value,0.0,INF)
@export var max_health := 100.0:
	set(value):
		max_health = clamp(value,0.0,INF)
@export var health_regen := 2.0:
	set(value):
		health_regen = value
@export var damage := 20.0:
	set(value):
		damage = clamp(value,0.0,INF)
@export var attack_speed := 1.0:
	set(value):
		attack_speed = clamp(value,0.0,INF)
@export var attack_range := 60.0:
	set(value):
		attack_range = clamp(value,0.0,INF)
@export var knockback := 100.0:
	set(value):
		knockback = clamp(value,0.0,INF)
@export var aggro_range := 750.0:
	set(value):
		aggro_range = clamp(value,0.0,INF)
@export var dodge_probability := 10.0
@export var parry_probability := 5.0
@export var block_probability := 40.0
@export var flat_block_power := 0.0
@export var percent_block_power := 50.0

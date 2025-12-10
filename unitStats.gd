extends Resource
class_name UnitStats

var strength : int = 0
var dexterity : int = 0
var endurance : int = 0
var intellect : int = 0
var faith : int = 0
var attunement : int = 0


@export var type = "Default Stickman"
@export var icon: Texture2D
@export var description: String = ""
@export var team : Team
@export var sprite_color := Color(255.0,255.0,255.0)

@export var speed : float = 100.0
@export var max_health : float = 100.0
@export var health_regen : float = 2.0
@export var aggro_range : float = 750.0
@export var dodge_probability : float = 10.0
@export var parry_probability : float = 5.0
@export var block_probability : float = 40.0
@export var flat_block_power : float = 0.0
@export var percent_block_power : float = 50.0

@export var damage : float = 20.0
@export var attack_speed : float = 1.0
@export var attack_range : float = 60.0
@export var knockback : float = 100.0

extends Resource
class_name ArenaFightConfig

@export var spawn_delay_between_units: float = 0.15  # seconds between each unit spawning
@export var countdown_duration: float = 3.0
@export var post_fight_delay: float = 2.0            # seconds before returning to circuit
@export var arena_radius: float = 300.0              # radius of the circular arena
@export var spawn_radius: float = 60.0               # radius around team spawn point
@export var simulation_speed: float = 1.0

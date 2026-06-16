extends Resource
class_name ProjectileData

@export var hitbox_data: HitboxData
@export var speed: float = 250.0             # movement speed
@export var launch_height: float = 16.0      # starting height above ground
@export var launch_velocity: float = 20.0   # initial upward velocity
@export var gravity: float = 30.0           # downward pull per second
@export var size: float = 16.0               # 'height' used for collisions
@export var sprite: Texture2D = null
@export var shadow_scale: float = 0.5        # size of the shadow, 0.0 to disable shadow
@export var piercing: bool = false           # passes through targets on true
@export var max_lifetime: float = INF        # duration before automatic despawn
@export var max_range: float = 5000.0        # automatic despawn distance

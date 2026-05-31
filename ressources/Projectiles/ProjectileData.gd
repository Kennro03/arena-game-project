extends Resource
class_name ProjectileData

@export var hitbox_data: HitboxData
@export var speed: float = 400.0             # movement speed
@export var launch_height: float = 60.0      # starting height above ground
@export var launch_velocity: float = 150.0   # initial upward velocity
@export var gravity: float = 300.0           # downward pull per second
@export var size: float = 8.0                # 'height' used for collisions
@export var sprite: Texture2D = null
@export var shadow_scale: float = 0.5        # size of the shadow, 0.0 to disable shadow
@export var piercing: bool = false           # passes through targets
@export var max_range: float = 5000.0        # despawn distance

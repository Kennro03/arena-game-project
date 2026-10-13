extends Node2D
class_name Projectile

enum BuffableStats {
	SPEED,
	SIZE,
	LAUNCH_VELOCITY,
	GRAVITY,
	PIERCING,
	MAX_LIFETIME,
	MAX_RANGE,
}

@export var projectile_data: ProjectileData
@export var _hitbox : Hitbox = null

var hit_data: HitData
var direction: Vector2
var _current_height: float = 0.0
var _vertical_velocity: float = 0.0
var _distance_traveled: float = 0.0
var _hit_targets: Array[Unit] = []
var _lifetime : float = 0.0
var _bounce_count: int = 0

@onready var sprite: Sprite2D = $ProjectileSpriteHeightOffset/ProjectileSprite
@onready var shadow: Sprite2D = $ShadowSprite2D
@onready var _wall_ray: RayCast2D = $WallRayCast2D
@onready var projectile_sprite_offset: Node2D = $ProjectileSpriteHeightOffset

func setup(data: ProjectileData, hit: HitData, dir: Vector2) -> void:
	projectile_data = data
	hit_data = hit
	direction = dir.normalized()
	_current_height = data.launch_height
	_vertical_velocity = data.launch_velocity
	
	# spawn hitbox as child using projectile's hitbox_data
	_hitbox = Hitbox.new()
	add_child(_hitbox)
	_hitbox.setup(data.hitbox_data, hit)
	_hitbox.hitbox_data.duration = INF     #make sure hitbox doesn't despawn without the projectile
	
	# intercept hits to apply height check before forwarding
	_hitbox.target_hit.connect(_on_target_detected)
	
	if data.sprite:
		sprite.texture = data.sprite
		
		if data.shadow_visible :
			shadow.texture = data.sprite
		else :
			shadow.visible = false
	
	# rotate sprite to face direction
	shadow.rotation = direction.angle()
	sprite.rotation = direction.angle()
	
	_wall_ray.collision_mask = data.wall_collision_mask
	_wall_ray.enabled = data.wall_behavior != ProjectileData.WallBehavior.NONE
	_update_ray_direction()

func _update_ray_direction() -> void:
	# cast slightly ahead of movement to catch walls before we enter them
	_wall_ray.target_position = direction * (projectile_data.speed * 0.05 + 8.0)

func _physics_process(delta: float) -> void:
	if projectile_data :
		if _lifetime >= projectile_data.max_lifetime:
			_on_impact()
			return
		
		_lifetime += delta  
		
		# horizontal movement
		var movement := direction * projectile_data.speed * delta
		global_position += movement
		_distance_traveled += movement.length()
		
		# vertical arc
		_vertical_velocity -= projectile_data.gravity * delta
		_current_height += _vertical_velocity * delta
		
		# visual fall of the sprite
		projectile_sprite_offset.position.y = -_current_height
		
		if projectile_data.does_sprite_arc:
			var pitch := atan2(-_vertical_velocity, projectile_data.speed)
			sprite.rotation = direction.angle() + pitch
		
		# shadow fades and shrinks as projectile goes higher
		var height_ratio := clampf(_current_height / 50.0, 0.1, 1.0)
		shadow.modulate.a = clampf(1.0 - height_ratio * 0.7, 0.3, 1.0)
		shadow.scale = Vector2.ONE * clampf(1.0 - height_ratio * 0.4, 0.1, 1.0)
		
		# hit ground
		if _current_height <= 0.0:
			_on_impact()
			return
		
		# max range
		if _distance_traveled >= projectile_data.max_range:
			queue_free()
			
		if _wall_ray.enabled and _wall_ray.is_colliding():
			_handle_wall_collision()

func _handle_wall_collision() -> void:
	match projectile_data.wall_behavior:
		ProjectileData.WallBehavior.IMPACT:
			_on_impact()
		
		ProjectileData.WallBehavior.NONE:
			pass  # flies through — ray disabled anyway

func _on_target_detected(unit: Unit) -> void:
	# height check
	if _current_height > unit.unit_size + projectile_data.size:
		return  # flies over
	
	_hit_targets.append(unit)
	unit.resolve_hit(hit_data)
	
	if not projectile_data.piercing:
		_on_impact()

func _on_impact() -> void:
	# could spawn a ground effect here
	queue_free()

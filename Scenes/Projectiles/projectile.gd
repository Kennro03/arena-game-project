extends Node2D
class_name Projectile

@export var projectile_data: ProjectileData
var hit_data: HitData
@export var _hitbox : Hitbox = null

var direction: Vector2
var _current_height: float = 0.0
var _vertical_velocity: float = 0.0
var _distance_traveled: float = 0.0
var _hit_targets: Array[BaseUnit] = []
var _lifetime : float = 0.0

@onready var sprite: Sprite2D = %ProjectileSprite
@onready var shadow: Sprite2D = %ShadowSprite2D

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
		shadow.scale = Vector2.ONE * data.shadow_scale
	
	# rotate sprite to face direction
	rotation = direction.angle()
	

func _physics_process(delta: float) -> void:
	if _lifetime >= projectile_data.max_lifetime:
		_on_impact()
		return
	
	# horizontal movement
	var movement := direction * projectile_data.speed * delta
	global_position += movement
	_distance_traveled += movement.length()
	
	# vertical arc
	_vertical_velocity -= projectile_data.gravity * delta
	_current_height += _vertical_velocity * delta
	
	# visual fall of the sprite
	sprite.position.y = -_current_height
	
	# shadow fades and shrinks as projectile goes higher
	var height_ratio := clampf(_current_height / 200.0, 0.0, 1.0)
	shadow.modulate.a = clampf(1.0 - height_ratio * 0.7, 0.3, 1.0)
	shadow.scale = Vector2.ONE * projectile_data.shadow_scale * clampf(1.0 - height_ratio * 0.4, 0.5, 1.0)
	
	# hit ground
	if _current_height <= 0.0:
		_on_impact()
		return
	
	# max range
	if _distance_traveled >= projectile_data.max_range:
		queue_free()

func _on_target_detected(unit: BaseUnit) -> void:
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

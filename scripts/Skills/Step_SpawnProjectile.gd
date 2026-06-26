extends CastStep
class_name Step_SpawnProjectile

const PROJECTILE_SCENE := preload("uid://utyen8d0722")  

enum SpawnPattern {
	SINGLE,     # one projectile
	FAN,        # spread from origin around a direction
	RING,       # all directions equally
	RAIN,       # random positions around a point falling from above
	LINE,       # spawn projectiles in a straight line perpendicular to direction
	ARC,        # spawn projectiles along a curved arc
}

enum SpawnOrigin {
	CASTER,                  # from caster position
	TARGET,                  # from target position
	BETWEEN,                 # halfway between caster and target
	RANDOM_AROUND_CASTER,    # random point within radius of caster
	RANDOM_AROUND_TARGET,    # random point within radius of target
	CASTER_OFFSET,            # caster position + spawn_offset
	TARGET_OFFSET,           # target position + spawn_offset
}

@export var projectile_data: ProjectileData
@export var spawn_from_weapon: bool = false  # use weapon's projectile_data instead
@export var damage : float = 0.0
@export var damage_type: HitData.DamageType = HitData.DamageType.PIERCE
@export var damage_scalings: Array[StatScaling] = []
@export var damage_multiplier: float = 1.0

@export_group("Pattern")
@export var pattern: SpawnPattern = SpawnPattern.SINGLE
@export var projectile_count: int = 1       # number of projectiles per volley
@export var volley_count: int = 1           # how many times to repeat the pattern
@export var volley_delay: float = 0.1       # delay between each volley
@export var fan_angle: float = 45.0         # total spread in degrees for FAN
@export var line_spacing := 20.0            # for LINE, distance between each projectile
@export var rain_height: float = 300.0      # For RAIN, how far above target they spawn
@export var rain_launch_gravity: float = 300.0 # For RAIN, how fast do projectiles fall
@export var rain_delay_min: float = 0.05    # For RAIN, min delay between individual drops
@export var rain_delay_max: float = 0.15    # For RAIN, max delay for variety

@export_group("Origin")
@export var origin: SpawnOrigin = SpawnOrigin.CASTER
@export var spawn_radius: float = 80.0       # for RANDOM_AROUND variants
@export var spawn_offset: Vector2 = Vector2.ZERO  # for OFFSET origin


func _get_spawn_position(caster: BaseUnit, target: BaseUnit) -> Vector2:
	match origin:
		SpawnOrigin.CASTER:
			return caster.global_position
		SpawnOrigin.TARGET:
			return target.global_position
		SpawnOrigin.RANDOM_AROUND_CASTER:
			return caster.global_position + _random_in_radius(spawn_radius)
		SpawnOrigin.RANDOM_AROUND_TARGET:
			return target.global_position + _random_in_radius(spawn_radius)
		SpawnOrigin.CASTER_OFFSET:
			return caster.global_position + spawn_offset
		SpawnOrigin.TARGET_OFFSET:
			return target.global_position + spawn_offset
		SpawnOrigin.BETWEEN:
			return caster.global_position.lerp(target.global_position, 0.5)
	return caster.global_position

func _random_in_radius(radius: float) -> Vector2:
	# uniform distribution within circle, not just on edge
	var angle := randf_range(0.0, TAU)
	var dist := sqrt(randf()) * radius  # sqrt for uniform distribution
	return Vector2(cos(angle), sin(angle)) * dist

func _make_hit(caster: BaseUnit) -> HitData:
	var hit := HitData.new(caster)
	hit.hit_owner = caster
	
	var base := damage * damage_multiplier
	
	# apply stat scalings on top of base damage
	for scaling in damage_scalings:
		base += scaling.compute(caster.stats)
	
	hit.base_damage = base
	hit.attack_type = damage_type
	hit.is_critical = randf() <= caster.stats.current_crit_chance / 100.0
	if hit.is_critical:
		hit.base_damage *= caster.stats.current_crit_damage
	return hit

func execute(caster: BaseUnit, context: Dictionary, next: Callable) -> void:
	print("Spawn Projectile Called")
	_execute_volley(caster, context, 0, next)

func _execute_volley(caster: BaseUnit, context: Dictionary, volley_index: int, next: Callable) -> void:
	if volley_index >= volley_count:
		next.call()
		return
	
	var target := context.get("target") as BaseUnit
	if target == null or not is_instance_valid(target):
		printerr("Step_SpawnProjectile: no target")
		next.call()
		return
	
	var proj_data: ProjectileData = caster.weapon.projectile_data if spawn_from_weapon else projectile_data
	if proj_data == null:
		printerr("Step_SpawnProjectile: no projectile_data")
		next.call()
		return
	
	var spawn_pos := _get_spawn_position(caster, target)
	var base_dir := (target.global_position - caster.global_position).normalized()
	
	# fire current pattern iteration
	match pattern:
		SpawnPattern.SINGLE: _spawn_one(caster, proj_data, spawn_pos, base_dir)
		SpawnPattern.FAN:    _spawn_fan(caster, proj_data, spawn_pos, base_dir)
		SpawnPattern.RING:   _spawn_ring(caster, proj_data, spawn_pos)
		SpawnPattern.RAIN:   _spawn_rain_burst(caster, proj_data, target.global_position)
		SpawnPattern.LINE:   _spawn_line(caster, proj_data, spawn_pos, base_dir)
		SpawnPattern.ARC:
			push_warning("ARC pattern not yet implemented")
			_spawn_one(caster, proj_data, spawn_pos, base_dir)
	
	# schedule next volley
	if volley_delay > 0.0:
		caster.get_tree().create_timer(volley_delay).timeout.connect(func():
			_execute_volley(caster, context, volley_index + 1, next))
	else:
		_execute_volley(caster, context, volley_index + 1, next)

func _spawn_one(caster: BaseUnit, proj_data: ProjectileData, pos: Vector2, direction: Vector2) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	caster.get_tree().root.add_child(projectile)
	projectile.global_position = pos
	projectile.setup(proj_data, _make_hit(caster), direction)

func _spawn_fan(caster: BaseUnit, proj_data: ProjectileData, pos: Vector2, base_direction: Vector2) -> void:
	if projectile_count <= 1:
		_spawn_one(caster, proj_data, pos, base_direction)
		return
	var half_angle := deg_to_rad(fan_angle / 2.0)
	var angle_step := deg_to_rad(fan_angle) / (projectile_count - 1)
	for i in projectile_count:
		var angle := -half_angle + angle_step * i
		var direction := base_direction.rotated(angle)
		_spawn_one(caster, proj_data, pos, direction)

func _spawn_ring(caster: BaseUnit, proj_data: ProjectileData, pos: Vector2) -> void:
	var angle_step := TAU / projectile_count
	for i in projectile_count:
		var direction := Vector2.RIGHT.rotated(angle_step * i)
		_spawn_one(caster, proj_data, pos, direction)

func _spawn_line(caster: BaseUnit, proj_data: ProjectileData, pos: Vector2, direction: Vector2) -> void:
	var perpendicular := direction.rotated(PI / 2.0)
	var half := (projectile_count - 1) / 2.0
	for i in projectile_count:
		var offset := perpendicular * (i - half) * line_spacing
		_spawn_one(caster, proj_data, pos + offset, direction)

func _spawn_rain_burst(caster: BaseUnit, proj_data: ProjectileData, target_pos: Vector2) -> void:
	_spawn_rain_drop(caster, proj_data, target_pos, 0)

func _spawn_rain_drop(caster: BaseUnit, proj_data: ProjectileData, target_pos: Vector2, drop_index: int) -> void:
	if drop_index >= projectile_count:
		return
	
	# random landing position around target
	var land_pos := target_pos + _random_in_radius(spawn_radius)
	
	# spawn above landing position
	var spawn_pos := land_pos
	proj_data.launch_height = rain_height
	proj_data.launch_velocity = -rain_launch_gravity
	
	# direction straight down toward landing spot
	var direction := (land_pos - spawn_pos).normalized()
	
	_spawn_one(caster, proj_data, spawn_pos, direction)
	
	# schedule next drop with random delay
	var delay := randf_range(rain_delay_min, rain_delay_max)
	caster.get_tree().create_timer(delay).timeout.connect(func():
		_spawn_rain_drop(caster, proj_data, target_pos, drop_index + 1))

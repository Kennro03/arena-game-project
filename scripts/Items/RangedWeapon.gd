extends Weapon
class_name RangedWeapon

@export_group("Ranged_data")
@export var projectile_data: ProjectileData = null  #
@export var base_min_shooting_range: float = 100.0   # minimum range for ranged attacks
@export var base_projectile_damage_bonus : float = 0.0
@export var base_projectile_knockback_bonus : float = 0.0

var current_min_shooting_range : float
var current_projectile_damage_bonus : float
var current_projectile_knockback_bonus : float

const PROJECTILE_SCENE := preload("uid://utyen8d0722")

func _spawn_projectile(_spawn_position: Vector2, _target_position: Vector2, _hit_data: HitData) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	var direction := (_target_position - _spawn_position).normalized()
	
	owner.get_tree().root.add_child(projectile)
	projectile.global_position = _spawn_position
	projectile.setup(projectile_data, _hit_data, direction)

func _shoot_at_target(_target: Node2D, _hit_data: HitData) -> void:
	if projectile_data == null:
		printerr("RangedWeapon has no projectile_data")
		return
	var _proj_hitbox : HitboxData = projectile_data.hitbox_data
	
	_spawn_projectile(owner.global_position, _target.global_position, _hit_data)

func setup_base_stats_from_dict(dict : Dictionary) -> void : 
	projectile_data = dict.get("projectile_data",projectile_data)
	base_min_shooting_range = dict.get("min_shooting_range",base_min_shooting_range)
	base_projectile_damage_bonus = dict.get("projectile_damage_bonus",base_projectile_damage_bonus) 
	base_projectile_knockback_bonus = dict.get("projectile_knockback_bonus",base_projectile_knockback_bonus)
	super.setup_base_stats_from_dict(dict)

func recalculate_stats() -> void:
	current_min_shooting_range = base_min_shooting_range
	current_projectile_damage_bonus = base_projectile_damage_bonus
	current_projectile_knockback_bonus = base_projectile_knockback_bonus
	super.recalculate_stats()

func hit(target:Node2D, _hit: HitData)-> void:
	if owner == null:
		printerr("No owner ! Voiding hit")
		return
	
	if owner.global_position.distance_to(target.global_position) < current_min_shooting_range :
		_hit.attack_type = current_damage_type
		_hit.base_damage = current_damage
		_hit.knockback_force = current_knockback
		
		if _hit.is_critical :
			_hit.base_damage *= _hit.hit_owner.stats.current_crit_damage
		
		if current_hitbox != null : 
			_spawn_hitbox(target.global_position, _hit)
			attack_performed.emit(_hit.attack_type, current_endlag)
		elif target.has_method("resolve_hit") :
			target.resolve_hit(_hit)
			attack_performed.emit(_hit.attack_type, current_endlag)
		else :
			printerr("Trying to attack an unvalid target without a hitbox !")
	else :
		_hit.attack_type = current_damage_type
		_hit.base_damage = current_damage
		_hit.base_damage += current_projectile_damage_bonus
		_hit.knockback_force = current_knockback
		_hit.knockback_force += current_projectile_knockback_bonus
		
		if _hit.is_critical :
			_hit.base_damage *= _hit.hit_owner.stats.current_crit_damage
		
		_shoot_at_target(target,_hit)
		
		
		

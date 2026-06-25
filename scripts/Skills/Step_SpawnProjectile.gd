extends CastStep
class_name Step_SpawnProjectile

@export var projectile_data: ProjectileData
@export var spawn_from_weapon: bool = false  # use weapon's projectile_data instead
@export var damage_multiplier: float = 1.0
@export var damage_type: HitData.DamageType = HitData.DamageType.PIERCE

func execute(caster: BaseUnit, context: Dictionary, next: Callable) -> void:
	var target := context.get("target") as BaseUnit
	if target == null:
		next.call()
		return
	
	var proj_data : ProjectileData = caster.weapon.projectile_data if spawn_from_weapon else projectile_data
	if proj_data == null:
		printerr("Step_SpawnProjectile: no projectile_data")
		next.call()
		return
	
	var hit := HitData.new(caster)
	hit.hit_owner = caster
	hit.base_damage = (caster.weapon.current_damage if spawn_from_weapon else proj_data.base_damage) * damage_multiplier
	hit.attack_type = damage_type
	hit.is_critical = randf() <= caster.stats.current_crit_chance / 100.0
	if hit.is_critical:
		hit.base_damage *= caster.stats.current_crit_damage
	
	var projectile : Projectile = preload("uid://utyen8d0722").instantiate()
	caster.get_tree().root.add_child(projectile)
	projectile.global_position = caster.global_position
	var direction := (target.global_position - caster.global_position).normalized()
	projectile.setup(proj_data, hit, direction)
	
	next.call()  # don't wait for projectile to land

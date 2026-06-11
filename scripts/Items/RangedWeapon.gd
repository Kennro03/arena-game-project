extends Weapon
class_name RangedWeapon

@export_group("Ranged")
@export var projectile_data: RangedWeaponHitboxesData = null  # projectile hitbox data
@export var min_range: float = 150.0   # below this, uses melee fallback
@export var base_projectile_damage_mult: float = 1.0  # ranged hits can scale differently

@export_subgroup("Melee Fallback")
@export var melee_hitboxes_data: WeaponHitboxesData = null  # used when target is too close

const PROJECTILE_SCENE := preload("uid://utyen8d0722")

func _do_ranged_hit(target: Node2D, hit: HitData, is_heavy: bool) -> void:
	if projectile_data == null:
		printerr("RangedWeapon has no projectile_data")
		return
	#var proj_hitbox := projectile_data.heavy_hitbox if is_heavy else projectile_data.light_hitbox
	#_spawn_projectile(proj_hitbox, target.global_position, hit)

func _do_melee_hit(target: Node2D, hit: HitData) -> void:
	# use melee fallback hitboxes if set, otherwise direct resolve
	if melee_hitboxes_data != null:
		_spawn_hitbox(melee_hitboxes_data.light_hitbox, target.global_position, hit)
	elif target.has_method("resolve_hit"):
		target.resolve_hit(hit)

func _spawn_projectile(hitbox_data: HitboxData, target_position: Vector2, hit: HitData) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	owner.get_tree().root.add_child(projectile)
	projectile.global_position = owner.global_position
	var direction := (target_position - owner.global_position).normalized()
	#projectile.setup(hitbox_data, hit, direction)

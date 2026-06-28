extends SkillEffect
class_name SkillEffect_InflictHit

@export var damage: float = 10.0
@export var damage_type: HitData.DamageType = HitData.DamageType.NONE

func _apply_to(_target: BaseUnit, _caster: BaseUnit, _context: Dictionary) -> void:
	var hit := HitData.new(_caster)
	hit.base_damage = damage
	hit.attack_type = damage_type
	hit.hit_owner = _caster
	_target.resolve_hit(hit)

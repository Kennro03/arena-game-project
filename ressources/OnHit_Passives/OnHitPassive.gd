extends Resource
class_name OnHitPassive

@export var onhit_passive_name : String = ""
@export var onhit_passive_ID : String = ""
@export var onhit_passive_description : String = ""
@export var onhit_passive_icon : Texture2D = PlaceholderTexture2D.new()

enum HitTypeFilter { ANY, SLASH_ONLY, STAB_ONLY, BASH_ONLY, SHOOT_ONLY, CAST_ONLY, PUNCH_ONLY }
enum CritFilter { ANY, CRIT_ONLY, NON_CRIT_ONLY }

@export_group("trigger conditions")
@export var hit_type_filter : HitTypeFilter = HitTypeFilter.ANY
@export var crit_filter : CritFilter = CritFilter.ANY
@export var triggers_on_dodge : bool = false
@export var triggers_on_block : bool = false
@export var triggers_on_parry : bool = false

func should_trigger(hit: HitData) -> bool:
	match hit_type_filter:
		HitTypeFilter.SLASH_ONLY:
			if hit.attack_type != Weapon.AttackTypeEnum.SLASH:
				return false
		HitTypeFilter.STAB_ONLY:
			if hit.attack_type != Weapon.AttackTypeEnum.STAB:
				return false
		HitTypeFilter.BASH_ONLY:
			if hit.attack_type != Weapon.AttackTypeEnum.BASH:
				return false
		HitTypeFilter.SHOOT_ONLY:
			if hit.attack_type != Weapon.AttackTypeEnum.SHOOT:
				return false
		HitTypeFilter.CAST_ONLY:
			if hit.attack_type != Weapon.AttackTypeEnum.CAST:
				return false
		HitTypeFilter.PUNCH_ONLY:
			if hit.attack_type != Weapon.AttackTypeEnum.PUNCH:
				return false
	match crit_filter:
		CritFilter.CRIT_ONLY:
			if not hit.is_critical:
				return false
		CritFilter.NON_CRIT_ONLY:
			if hit.is_critical:
				return false
	return true

# Rename the overrideable part, make on_hit() final-ish
func on_hit(hit: HitData) -> void:
	if not should_trigger(hit):
		return
	_on_hit_effect(hit)

func _on_hit_effect(_hit: HitData) -> void:
	pass  # subclasses override this instead of on_hit()

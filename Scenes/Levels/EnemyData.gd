extends Resource
class_name EnemyData

@export var unit_data: UnitData  # can be stickmanUnitData, SlimeData, etc.
@export var base_cost: float = 10.0
@export var enemy_tier: EnemyTier = EnemyTier.COMMON

enum EnemyTier { COMMON, ELITE, BOSS }

func get_cost() -> float:
	# compute how much stronger this unit is vs its base stats
	var current_stats_total : int = unit_data.stats.body + unit_data.stats.mind
	var base_reference : int = unit_data.stats.base_strength + unit_data.stats.base_dexterity + unit_data.stats.base_endurance + unit_data.stats.base_intellect + unit_data.stats.base_faith + unit_data.stats.base_attunement
	
	var stat_multiplier : float = 1.0 if current_stats_total == 0.0 else current_stats_total / max(base_reference, 1.0)
	
	#maybe implement those bellow at a later date
	#var weapon_multiplier : float = _get_weapon_cost_multiplier()
	#var passive_multiplier : float = 1.0 + (0.15 * weapon.onHitPassives.size()) if weapon else 1.0
	var final_cost : float = base_cost * stat_multiplier 
	print("Stats total = " + str(current_stats_total) + ", base reference = " + str(base_reference) + ", stat_multiplier = " + str(stat_multiplier) + ", final cost = " + str(final_cost))
	return final_cost

func _get_weapon_cost_multiplier() -> float:
	if unit_data.weapon == null:
		return 1.0
	# compare current weapon stats to base
	var avg_boost : float = (
		(unit_data.weapon.current_damage / max(unit_data.weapon.base_damage, 0.01)) + (unit_data.weapon.current_attack_speed / max(unit_data.weapon.base_attack_speed, 0.01))
	) / 2.0
	return avg_boost

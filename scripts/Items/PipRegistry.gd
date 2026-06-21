extends Node
class_name PipRegistry

const WEAPON := [Item.ItemType.WEAPON]
const ARMOR := [Item.ItemType.ARMOR]
const ACC := [Item.ItemType.ACCESSORY]
const ALL := [Item.ItemType.WEAPON, Item.ItemType.ARMOR, Item.ItemType.ACCESSORY]
const GEAR := [Item.ItemType.ARMOR, Item.ItemType.ACCESSORY]

const ANYWEAPON := ""  
const MELEE_ONLY := "Weapon"
const RANGED_ONLY := "RangedWeapon"

const ADD := Buff.BuffType.ADD
const MULT := Buff.BuffType.MULTIPLY

const COMMON := Pip.Rarity.COMMON
const UNCOMMON := Pip.Rarity.UNCOMMON
const RARE := Pip.Rarity.RARE
const EPIC := Pip.Rarity.EPIC
const LEGENDARY := Pip.Rarity.LEGENDARY

const BUFF_TYPE := Pip.PipBuffType

static var pip_default_rarities_weigths := {
	Pip.Rarity.COMMON : 40.0,
	Pip.Rarity.UNCOMMON : 19.0,
	Pip.Rarity.RARE : 9.0,
	Pip.Rarity.EPIC : 4.0,
	Pip.Rarity.LEGENDARY : 1.0,
	Pip.Rarity.NEGATIVE : 6.0,
	Pip.Rarity.UNIQUE : 0.0,
}

# values array: [common, uncommon, rare, epic, legendary]
static var _table: Array = []
static var _built := false

static func _build_table() -> void:
	if _built:
		return 
	
	_built = true
	
	var S := Stats.BuffableStats      #owner stats
	var W := Weapon.BuffableStats     #weapon stats
	
	# format: [buff domain,   stat_index,            buff_type, min_pip_rarity, applicable_to,      [values...],          weight,    weapon_class]
	_table = [
		# ── Owner Attributes ──────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.STRENGTH,                  ADD,         COMMON,           ALL,   [1, 2, 3, 4, 8],           1.0],
		[Buff.Domain.UNIT,    S.DEXTERITY,                 ADD,         COMMON,           ALL,   [1, 2, 3, 4, 8],           1.0],
		[Buff.Domain.UNIT,    S.ENDURANCE,                 ADD,         COMMON,           ALL,   [1, 2, 3, 4, 8],           1.0],
		[Buff.Domain.UNIT,    S.INTELLECT,                 ADD,         COMMON,           ALL,   [1, 2, 3, 4, 8],           1.0],
		[Buff.Domain.UNIT,    S.FAITH,                     ADD,         COMMON,           ALL,   [1, 2, 3, 4, 8],           1.0],
		[Buff.Domain.UNIT,    S.ATTUNEMENT,                ADD,         COMMON,           ALL,   [1, 2, 3, 4, 8],           1.0],
		
		# ── Health ──────────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.MAX_HEALTH,                ADD,         COMMON,         GEAR,  [5, 10, 15, 20, 30],         1.0],
		[Buff.Domain.UNIT,    S.HEALTH_REGEN,              ADD,         COMMON,         GEAR,  [0.1, 0.2, 0.4, 0.7, 1],     0.7],
		
		# ── Movement ────────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.MOVEMENT_SPEED,            ADD,           RARE,         GEAR,  [10, 20, 30, 40, 50],        0.6],
		
		# ── Defenses ────────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.DODGE_PROBABILITY,        ADD,        UNCOMMON,         GEAR, [0.0, 0.5, 1.0,  1.5,  2.0],  0.8],
		[Buff.Domain.UNIT,    S.PARRY_PROBABILITY,        ADD,        UNCOMMON,         GEAR, [0.0, 0.5, 1.0,  1.5,  2.0],  0.7],
		[Buff.Domain.UNIT,    S.BLOCK_PROBABILITY,        ADD,        UNCOMMON,         GEAR, [0.0, 1.0,  1.5,  2.0, 2.5],  0.8],
		[Buff.Domain.UNIT,    S.FLAT_BLOCK_POWER,         ADD,          COMMON,         GEAR, [1.0, 2.0, 4.0,  6.0,  9.0],  0.8],
		#[Buff.Domain.UNIT,   S.PERCENT_BLOCK_POWER,      ADD,     RARE, GEAR, [0.0, 0.0, 3.0,  5.0,  8.0], 0.6],
		
		# ── Offense ─────────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.CRIT_CHANCE,              ADD,        UNCOMMON,          ALL, [0, 1, 2,  3.5,  5],          0.8],
		[Buff.Domain.UNIT,    S.CRIT_DAMAGE,              ADD,        UNCOMMON,          ALL, [0, 0.05, 0.1, 0.18, 0.25],   0.7],
		
		# ── Damage taken ────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.DAMAGE_TAKEN_MULTIPLIER, MULT,           RARE,          GEAR, [0.0, 0.0, 0.98, 0.96, 0.94], 0.5],
		
		# ── Accessories ─────────────────────────────────────────────────
		[Buff.Domain.UNIT,    S.ACCESSORY_LIMIT,          ADD,           EPIC,         ARMOR, [0.0, 0.0, 0.0, 1.0, 2.0],    0.2],
		
		# - Weapon stats
		[Buff.Domain.WEAPON,  W.DAMAGE,                   ADD,         COMMON,        WEAPON,   [0.5, 1, 1.5, 2, 3],        2.0],
		[Buff.Domain.WEAPON,  W.ATTACK_SPEED,             ADD,         COMMON,        WEAPON,   [0.1, 0.2, 0.3, 0.4, 0.5],  2.0],
		[Buff.Domain.WEAPON,  W.ATTACK_RANGE,             ADD,         COMMON,        WEAPON,   [10, 20, 30, 40, 50],       2.0],
		[Buff.Domain.WEAPON,  W.KNOCKBACK,                ADD,         COMMON,        WEAPON,   [10, 20, 30, 40, 50],       2.0],
		
		# - Ranged weapon only
		[Buff.Domain.WEAPON,  W.PROJECTILE_DAMAGE_BONUS,  ADD,       UNCOMMON,        WEAPON,   [0, 0.5, 1, 1.5, 2],        2.0,    RANGED_ONLY],
		[Buff.Domain.WEAPON,W.PROJECTILE_KNOCKBACK_BONUS, ADD,         COMMON,        WEAPON,   [10, 20, 30, 40, 50],       2.0,    RANGED_ONLY],
		
		]


static func _get_value(entry: Array, pip_rarity: Pip.Rarity) -> float:
	var values: Array = entry[5]
	var index := int(pip_rarity)
	# clamp to available values since NEGATIVE and UNIQUE aren't in the 5-value array
	index = clamp(index, 0, values.size() - 1)
	var v = values[index]
	# handle Vector2 ranges by picking random value in range
	if v is Vector2:
		return randf_range(v.x, v.y)
	return float(v)

static func _can_appear(entry: Array, item: Item, pip_rarity: Pip.Rarity) -> bool:
	var min_rarity: Pip.Rarity = entry[3]
	var applicable = entry[4]
	var weapon_class: String = entry[7] if entry.size() > 7 else ""
	
	if not (item.item_type in applicable):
		return false
	if int(pip_rarity) < int(min_rarity):
		return false
	
	if weapon_class != "" and item is Weapon:
		match weapon_class:
			RANGED_ONLY:
				if not item is RangedWeapon:
					return false
			MELEE_ONLY:
				if item is RangedWeapon:
					return false
	
	return true

static func roll_pips(item: Item, _pip_rarity_weigths: Dictionary = pip_default_rarities_weigths) -> Array[Pip]:
	_build_table()
	
	var count : int
	match item.item_type:
		Item.ItemType.WEAPON :
			count = item.pip_count
		Item.ItemType.ACCESSORY :
			count = item.guaranteed_pips_count
		#Item.ItemType.ARMOR :
		#	count = item.pip_count
		_ :
			return []
	
	if count == 0:
		return []
	
	var result: Array[Pip] = []
	var used_stats: Array = []
	var attempts := 0
	
	while result.size() < count and attempts < 50:
		attempts += 1
		
		var new_pip : Pip = Pip.new()
		new_pip.pip_rarity = generate_pip_rarity(_pip_rarity_weigths)  
		
		var pool := _table.filter(func(e): return _can_appear(e, item, new_pip.pip_rarity))
		if pool.is_empty():
			break
		
		var entry := _weighted_pick(pool)
		
		var value := _get_value(entry, new_pip.pip_rarity)
		if value == 0.0:
			continue
		used_stats.append(entry[1])
		
		var buff := Buff.new()
		buff.domain = entry[0]
		buff.stat_index = entry[1]
		buff.buff_type = entry[2]
		buff.buff_amount = value
		new_pip.buff = buff
		result.append(new_pip)
		#print("Pip generated : " + str(new_pip))
	
	return result

static func _weighted_pick(pool: Array) -> Array:
	var total := 0.0
	for e in pool:
		total += e[6]
	var roll := randf_range(0.0, total)
	for e in pool:
		roll -= e[6]
		if roll <= 0:
			return e
	return pool[-1]

static func generate_pip_rarity(pip_rarity_weights : Dictionary = pip_default_rarities_weigths, fallback : Pip.Rarity = Pip.Rarity.COMMON) -> Pip.Rarity :
	var totalWeights : float = 0.0
	var _accumulatedweight : float = 0.0
	
	for weight in pip_rarity_weights.values():
		totalWeights += weight
	
	if totalWeights <= 0:
		printerr("Returned fallback rarity (common).")
		return fallback
	
	var roll : float = randf_range(0.0, totalWeights)
	
	## Pick a random item based on the random weight
	for key in pip_rarity_weights: 
		var w : int = pip_rarity_weights[key]
		if w <= 0 :
			continue
		_accumulatedweight += w
		if roll <= _accumulatedweight:
			return key
	
	
	printerr("NO KEY MADE CHOSEN DURING PIP GENERATION")
	return fallback

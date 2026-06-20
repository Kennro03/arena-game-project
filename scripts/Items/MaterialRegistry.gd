extends Node
class_name MaterialRegistry

static var _materials: Array[ItemMaterial] = []
static var _loaded := false

# default weights per tier 
static var default_tier_weights := {
	ItemMaterial.Material_Tiers.TIER_0: 0.0,
	ItemMaterial.Material_Tiers.TIER_1: 30.0,
	ItemMaterial.Material_Tiers.TIER_2: 10.0,
	ItemMaterial.Material_Tiers.TIER_3: 4.0,
	ItemMaterial.Material_Tiers.TIER_4: 1.0,
	ItemMaterial.Material_Tiers.SPECIAL: 0.5,
}

static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_load_from("res://ressources/Materials/")

static func _load_from(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if dir.current_is_dir():
			_load_from(path + file + "/")
		elif file.get_extension() == "tres":
			var mat : ItemMaterial = load(path + file)
			if mat:
				_materials.append(mat)
		file = dir.get_next()
	dir.list_dir_end()

static func roll_material(
	tier_weights: Dictionary = default_tier_weights,
	allowed_tiers: Array = []  # empty = all tiers allowed
	) -> ItemMaterial:
	ensure_loaded()
	
	var pool := _materials.filter(func(m):
		return allowed_tiers.is_empty() or m.tier in allowed_tiers)
	
	if pool.is_empty():
		printerr("MaterialRegistry: no materials available")
		return null
	
	# First pick a tier then pick a material within that tier
	var tier := _roll_tier(pool, tier_weights)
	var tier_pool := pool.filter(func(m): return m.tier == tier)
	
	if tier_pool.is_empty():
		return pool.pick_random()  # fallback
	return tier_pool.pick_random()

static func _roll_tier(pool: Array, weights: Dictionary) -> ItemMaterial.Material_Tiers:
	# only include tiers that have at least one material in the pool
	var available_tiers := {}
	for m in pool:
		if not available_tiers.has(m.tier):
			available_tiers[m.tier] = weights.get(m.tier, 0.0)
	
	var total := 0.0
	for w in available_tiers.values():
		total += w
	if total <= 0:
		return pool[0].tier
	
	var roll := randf_range(0.0, total)
	for tier in available_tiers:
		roll -= available_tiers[tier]
		if roll <= 0:
			return tier
	return pool[0].tier

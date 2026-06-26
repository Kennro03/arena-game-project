extends Item
class_name Weapon

signal attack_performed(damage_type : HitData.DamageType, endlag: float)

enum WeaponCategoryEnum { LIGHT, MEDIUM, HEAVY }
enum WeaponTypeEnum { UNARMED, DAGGER, GAUNTLET, WAND, SWORD, SPEAR, FOCI_STAFF, HAMMER, GREATSWORD, BOW }

enum BuffableStats {
	ATTACK_SPEED,
	ATTACK_RANGE,
	DAMAGE,
	KNOCKBACK,
	PROJECTILE_DAMAGE_BONUS,   
	PROJECTILE_KNOCKBACK_BONUS,
	MIN_SHOOTING_RANGE,
}

static var buffable_stat_icons : Dictionary = {
	BuffableStats.DAMAGE: preload("uid://br85td3jaqel7"),
	BuffableStats.ATTACK_SPEED: preload("uid://w6i0f1b7rffo"),
	BuffableStats.ATTACK_RANGE: preload("uid://d0tjxydbev5m4"),
	BuffableStats.KNOCKBACK: preload("uid://brfm5e6515tqd"),
	BuffableStats.PROJECTILE_DAMAGE_BONUS : PlaceholderTexture2D.new(),
	BuffableStats.PROJECTILE_KNOCKBACK_BONUS : PlaceholderTexture2D.new(),
	BuffableStats.MIN_SHOOTING_RANGE : PlaceholderTexture2D.new(),
}
static var debug_weapon_sprites : Dictionary = {
	WeaponTypeEnum.UNARMED: null,
	WeaponTypeEnum.DAGGER: preload("uid://c64v6mkj70qpn"),
	WeaponTypeEnum.GAUNTLET: preload("uid://cgt11mipx5r5p"),
	WeaponTypeEnum.WAND: preload("uid://bisn55jrtqnxi"),
	WeaponTypeEnum.SWORD: preload("uid://ds2300iqhvnig"),
	WeaponTypeEnum.SPEAR: preload("uid://drtgerm1gchkr"),
	WeaponTypeEnum.FOCI_STAFF: preload("uid://c56q6fj8mor03"),
	WeaponTypeEnum.HAMMER: preload("uid://bndegctnnxbsx"),
	WeaponTypeEnum.GREATSWORD: preload("uid://c655s547o85vn"),
	WeaponTypeEnum.BOW: preload("uid://bp6g4vjifxu5e"),
}

@export_group("Weapon data")
@export var weaponCategory : WeaponCategoryEnum
@export var weaponType : WeaponTypeEnum
@export var weaponSprite : Texture2D = null : 
	get: return weaponSprite if weaponSprite != null else debug_weapon_sprites[weaponType]
@export var weapon_material : ItemMaterial = preload("uid://b64ruo6aqmuk") :
	set(new_mat):
		weapon_material = new_mat
		recalculate_stats()


@export_subgroup("Base weapon Stats","base_")
@export var base_attack_speed : float = 1.0
@export var base_attack_range : float = 100.0
@export var base_damage_type: HitData.DamageType = HitData.DamageType.BLUNT
@export var base_damage: float = 5.0
@export var base_knockback : float = 50.0
@export var base_endlag : float = 0.15
@export var base_crit_endlag : float = 0.15

@export_group("Hitboxes")
@export var base_hitbox: HitboxData = null
@export var base_crit_hitbox: HitboxData = null
var current_hitbox: HitboxData = null :
	get:
		return base_hitbox if current_hitbox == null else current_hitbox
var current_crit_hitbox: HitboxData = null :
	get:
		return base_crit_hitbox if current_crit_hitbox == null else current_crit_hitbox

@export_subgroup("Passives")
@export var statChanges : Array[Buff] = []
@export var onHitPassives : Array[OnHitPassive] = []

@export_subgroup("Scalings")
@export var attack_speed_scalings : Array[StatScaling] = []
@export var attack_range_scalings : Array[StatScaling] = []
@export var damage_scalings : Array[StatScaling] = []
@export var knockback_scalings : Array[StatScaling] = []

@export_subgroup("Pip related")
@export var pips : Array[Pip] = []
@export var guaranteed_pips_count : int = 0            #number of pips rolled upon generation, unused by misc or quest item types
@export var random_pips_amount : Vector2 = Vector2(0,0)
@export var allowed_pips_list : Array[Pip] = [] # select pips from this array, generate random pips when empty
@export var custom_pip_rarities_weigths : Dictionary = PipRegistry.pip_default_rarities_weigths

@export_subgroup("Animations")
@export var allowed_animations: Array[String] = ["slash","stab","bash"] # Slash, Stab, Bash, etc
@export var exclusive_animations : Array[String] = []

var current_attack_speed : float
var current_attack_range : float
var current_damage_type : HitData.DamageType
var current_damage: float
var current_knockback : float
var current_endlag : float
var current_crit_endlag : float

var weapon_stat_buffs: Array[Buff] = []
var owner: BaseUnit

func _init() -> void:
	item_type = Item.ItemType.WEAPON

func setup_stats() -> void :
	if owner == null:
		printerr("No owner!")
		return
	recalculate_stats() 

func setup_base_stats_from_dict(dict : Dictionary) -> void : 
	base_attack_speed = dict.get("attack_speed",base_attack_speed)
	base_attack_range = dict.get("attack_range",base_attack_range)
	base_damage = dict.get("damage",base_damage)
	base_knockback = dict.get("knockback",base_knockback)
	recalculate_stats()

func add_weapon_buff(buff: Buff) -> void :
	if buff in weapon_stat_buffs:
		return
	weapon_stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_weapon_buff(buff: Buff) -> void :
	weapon_stat_buffs.erase(buff)
	recalculate_stats.call_deferred()

func clear_weapon_buffs() -> void:
	weapon_stat_buffs.clear()
	recalculate_stats()

func _on_owner_stats_change() -> void:
	recalculate_stats()

func apply_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.add_buff(buff)
	for pip in pips:
		if pip.buff != null and pip.buff.domain == Buff.Domain.UNIT:
			stats.add_buff(pip.buff)

func remove_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.remove_buff(buff)
	for pip in pips:
		if pip.buff != null and pip.buff.domain == Buff.Domain.UNIT:
			stats.remove_buff(pip.buff)

func recalculate_stats() -> void :
	reset_current_stats()
	
	var stat_multipliers: Dictionary = {} #Amount to multiply stats by
	var stat_addends: Dictionary = {} #Amount to add to included stats
	
	#Stat scaling logic
	for scaling in attack_range_scalings : 
		current_attack_range += scaling.compute(owner.stats)
	for scaling in attack_speed_scalings : 
		current_attack_speed += scaling.compute(owner.stats)
	for scaling in damage_scalings : 
		current_damage += scaling.compute(owner.stats)
	for scaling in knockback_scalings : 
		current_knockback += scaling.compute(owner.stats)
	
	#Weapon buffs
	for buff in weapon_stat_buffs :
		var stat_name: String = BuffableStats.keys()[buff.stat_index].to_lower()
		match buff.buff_type:
			Buff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
			
			Buff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] *= buff.buff_amount
				#if stat_multipliers[stat_name] < 0.0:
				#	stat_multipliers[stat_name] = 0.0
	
	for stat_name in stat_multipliers:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, snapped(get(cur_property_name) * stat_multipliers[stat_name],0.01))
	
	for stat_name in stat_addends:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, snapped(get(cur_property_name) + stat_addends[stat_name],0.01))

func reset_current_stats() -> void:
	current_attack_range = base_attack_range
	current_attack_speed = base_attack_speed
	current_damage = base_damage
	current_knockback = base_knockback
	
	current_damage_type = base_damage_type  
	current_endlag = base_endlag
	current_crit_endlag = base_crit_endlag
	
	_apply_material_stats()

func _apply_material_stats() -> void:
	if weapon_material == null:
		return
	for buff in weapon_material.guaranteed_stat_changes:
		if buff.domain != Buff.Domain.WEAPON:
			continue
		var stat_name : String = Weapon.BuffableStats.keys()[buff.stat_index].to_lower()
		var prop : String = "current_" + stat_name
		match buff.buff_type:
			Buff.BuffType.ADD:
				set(prop, get(prop) + buff.buff_amount)
			Buff.BuffType.MULTIPLY:
				set(prop, get(prop) * buff.buff_amount)

func generate_attack_type(_weightedDict : WeaponAttackTypesDictionnary, fallback := HitData.DamageType.BLUNT) -> HitData.DamageType :
	var totalWeights : float = 0
	var accumulatedweight : int = 0
	for weight in _weightedDict.CurrentAttackTypesWeights.values():
		totalWeights += weight
	
	if totalWeights <= 0:
		printerr("Returned fallback in generating attack type.")
		return fallback
	
	#If no key made chosen error appears, error may come from here
	var randomWeight : float = randi_range(1, int(totalWeights)) 
	
	## Pick a random item based on the random weight
	for key in _weightedDict.CurrentAttackTypesWeights: 
		var w : int = _weightedDict.CurrentAttackTypesWeights[key]
		if w <= 0 :
			continue
		accumulatedweight += w
		if randomWeight <= accumulatedweight:
			return key
	printerr("NO KEY MADE CHOSEN")
	return fallback

func hit(target:Node2D, _hit: HitData)-> void:
	if owner == null:
		printerr("No owner ! Voiding hit")
		return
	
	##var attack : DamageType = generate_attack_type(attackTypes)
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

func _spawn_hitbox(target_position: Vector2, _hit: HitData, _size_mult: float = 1.0) -> void:
	if current_hitbox == null:
		printerr("No hitbox data on %s's %s, not spawning hitbox" % [_hit.hit_owner.display_name ,item_name])
		return
	var temp_hitbox_data : HitboxData = current_hitbox.duplicate(true) # create a temporary duplicate as to not modify original resource's size
	var hitbox := Hitbox.new()
	
	temp_hitbox_data.size *= _size_mult    #allows increased hitbox sizing
	owner.get_tree().root.add_child(hitbox)  # add to scene, not to unit
	hitbox.global_position = target_position #place hitbox on target_position
	hitbox.rotation = target_position.angle_to_point(_hit.hit_owner.global_position) #rotate hitbox towards target_position
	hitbox.setup(temp_hitbox_data, _hit)
	hitbox.target_hit.connect(func(unit: BaseUnit):
		unit.resolve_hit(_hit))

func get_color_palette() -> Texture2D :
	return weapon_material.material_color_palette if weapon_material != null else preload("uid://dv8kdjtdqrghu")

func generate_pips(rarity_weights: Dictionary = custom_pip_rarities_weigths) -> void:
	pips = PipRegistry.roll_pips(self, rarity_weights)
	apply_pips()

func apply_pips() -> void:
	for pip in pips:
		if pip.buff == null:
			continue
		match pip.buff.domain:
			Buff.Domain.WEAPON:
				weapon_stat_buffs.append(pip.buff)
			_:
				pass

func get_value() -> int:
	var value : int = base_value
	for pip in pips :
		value += pip.get_pip_value()
	if weapon_material : 
		value *= int(weapon_material.value_multiplier)
	return value 

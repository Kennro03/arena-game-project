extends Resource
class_name Weapon

signal attack_performed(attack_type:AttackTypeEnum, endlag: float)

enum WeaponCategoryEnum { LIGHT, MEDIUM, HEAVY }
enum WeaponTypeEnum { UNARMED, DAGGER, SWORD, HAMMER, STAFF }
enum AttackTypeEnum { LIGHTATTACK, HEAVYATTACK}
enum BuffableStats {
	ATTACK_SPEED,
	ATTACK_RANGE,
	DAMAGE,
	KNOCKBACK,
}

@export var weaponName : String
@export var weaponType : WeaponTypeEnum
@export var weaponCategory : WeaponCategoryEnum

@export var description : String
@export var icon : Texture2D
@export var spriteSheet : CompressedTexture2D = preload("res://ressources/Sprites/Units/Stickman/UnarmedStickman.png")

@export var base_attack_speed : float = 1.0
@export var base_attack_range : float = 100.0
@export var base_damage: float = 5.0
@export var base_knockback : float = 50.0

var current_attack_speed : float
var current_attack_range : float
var current_damage: float
var current_knockback : float

@export var attack_speed_scalings : Array[StatScaling] = []
@export var attack_range_scalings : Array[StatScaling] = []
@export var damage_scalings : Array[StatScaling] = []
@export var knockback_scalings : Array[StatScaling] = []

@export var statChanges : Array[StatBuff] = []
@export var onHitEffects : Array[StatusEffect]

@export var attackTypes : Dictionary = {
	AttackTypeEnum.LIGHTATTACK : 8,
	AttackTypeEnum.HEAVYATTACK : 2,
}

@export var light_endlag :float = 0.15
@export var heavy_endlag :float = 0.6

var weapon_stat_buffs: Array[WeaponStatBuff] = []
var owner: Node2D

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

func add_weapon_buff(buff: WeaponStatBuff) -> void :
	if buff in weapon_stat_buffs:
		return
	weapon_stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_weapon_buff(buff: WeaponStatBuff) -> void :
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

func remove_owner_buffs(stats: Stats):
	for buff in statChanges:
		stats.remove_buff(buff)

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
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			WeaponStatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
			
			WeaponStatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] += buff.buff_amount
				
				if stat_multipliers[stat_name] < 0.0:
					stat_multipliers[stat_name] = 0.0
	
	for stat_name in stat_multipliers:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	for stat_name in stat_addends:
		var cur_property_name : String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

func reset_current_stats() -> void:
	current_attack_range = base_attack_range
	current_attack_speed = base_attack_speed
	current_damage = base_damage
	current_knockback = base_knockback

func generate_item(_weightedDict : Dictionary, fallback := AttackTypeEnum.LIGHTATTACK) -> AttackTypeEnum :
	var totalWeights : float = 0
	var accumulatedweight : int = 0
	for weight in _weightedDict.values():
		totalWeights += weight
	
	if totalWeights <= 0:
		printerr("Returned fallback in generating item.")
		return fallback
	
	#If no key made chosen error appears, error may come from here
	var randomWeight : float = randi_range(1, int(totalWeights)) 
	
	## Pick a random item based on the random weight
	for key in _weightedDict: 
		var w : int = _weightedDict[key]
		if w <= 0 :
			continue
		accumulatedweight += w
		if randomWeight <= accumulatedweight:
			return key
	printerr("NO KEY MADE CHOSEN")
	return fallback

func lightHit(target:Node2D, attack_damage:float, knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used light hit")
	var hit_result = HitData.new(owner,attack_damage, knockback_direction,current_knockback)
	
	#also apply on hit passive and hediff effects once hediffs are in place
	for effect in onHitEffects :
		hit_result.status_effects.append(effect)
	
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)
	attack_performed.emit(AttackTypeEnum.LIGHTATTACK, light_endlag)

func heavyHit(target:Node2D, attack_damage:float,  knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used heavy hit")
	var hit_result = HitData.new(owner,attack_damage*1.2, knockback_direction,current_knockback*3.5)
	
	#also apply on hit passive and hediff effects once hediffs are in place
	for effect in onHitEffects :
		hit_result.status_effects.append(effect)
	
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)
	attack_performed.emit(AttackTypeEnum.HEAVYATTACK, heavy_endlag)

func hit(target:Node2D, damage_mult: float = 1.0, knockback_direction:= Vector2.ZERO)-> void:
	if owner == null:
		printerr("No owner ! Voiding hit")
		return
	
	var attack : AttackTypeEnum = generate_item(attackTypes)
	var final_damage := current_damage * damage_mult
	#print ("Generated item : " + str(attack))
	match attack :
		AttackTypeEnum.LIGHTATTACK:
			lightHit(target, final_damage, knockback_direction)
		AttackTypeEnum.HEAVYATTACK:
			heavyHit(target, final_damage, knockback_direction)

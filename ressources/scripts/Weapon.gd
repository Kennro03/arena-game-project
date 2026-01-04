extends Resource
class_name Weapon

signal attack_performed(attack_type:AttackTypeEnum, endlag: float)

enum WeaponCategoryEnum { LIGHT, MEDIUM, HEAVY }
enum WeaponTypeEnum { UNARMED, DAGGER, SWORD, HAMMER, STAFF }
enum AttackTypeEnum { LIGHTATTACK, HEAVYATTACK, SPECIALATTACK}

@export var weaponName : String
@export var weaponType : WeaponTypeEnum
@export var weaponCategory : WeaponCategoryEnum

@export var description : String
@export var icon : Texture2D

@export var attack_speed : float
@export var attack_range : float
@export var damage: float
@export var knockback : float

@export var statChanges : Array[StatBuff]
@export var attackTypes : Dictionary = {
	AttackTypeEnum.LIGHTATTACK : 8,
	AttackTypeEnum.HEAVYATTACK : 2,
	AttackTypeEnum.SPECIALATTACK : 0
}

@export var light_endlag :float = 0.15
@export var heavy_endlag :float = 0.6
@export var special_endlag :float = 0.4

func generate_item(_weightedDict : Dictionary):
	var totalWeights : float = 0
	for key in _weightedDict:
		totalWeights += _weightedDict[key]
	var accumulatedweight : int = 0
	var randomWeight : float = randi_range(0, int(totalWeights))
	## Pick a random item based on the random weight
	for key in _weightedDict: 
		accumulatedweight += _weightedDict[key]
		if randomWeight <= accumulatedweight:
			return int(key)
	print("NO KEY MADE CHOSEN: REPEAT")

func applyStatChanges()-> void:
	for buff in statChanges : 
		#apply stat changes to the stickman equipping the weapon
		pass

func lightHit(target:Node2D, attack_damage:float, knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used light hit")
	var hit_result = HitData.new(attack_damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)
	attack_performed.emit(AttackTypeEnum.LIGHTATTACK, light_endlag)

func heavyHit(target:Node2D, attack_damage:float,  knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used heavy hit")
	var hit_result = HitData.new(attack_damage*1.10, knockback_direction,knockback*3.5)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)
	attack_performed.emit(AttackTypeEnum.HEAVYATTACK, heavy_endlag)

func specialHit(target:Node2D, attack_damage:float,  knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used special hit")
	var hit_result = HitData.new(attack_damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)
	attack_performed.emit(AttackTypeEnum.SPECIALATTACK, special_endlag)

func hit(target:Node2D, damage_mult: float = 1.0, knockback_direction:= Vector2.ZERO)-> void:
	var attack : AttackTypeEnum = generate_item(attackTypes)
	var final_damage := damage * damage_mult
	
	match attack :
		AttackTypeEnum.LIGHTATTACK:
			lightHit(target, final_damage, knockback_direction)
		AttackTypeEnum.HEAVYATTACK:
			heavyHit(target, final_damage, knockback_direction)
		AttackTypeEnum.SPECIALATTACK:
			specialHit(target, final_damage, knockback_direction)

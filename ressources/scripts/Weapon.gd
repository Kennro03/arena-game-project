extends Resource
class_name Weapon

@export var weaponName : String
@export var description : String
@export var icon : Texture2D

enum WeaponTypeEnum { LIGHT, MEDIUM, HEAVY, SPECIAL }
@export var weaponType : WeaponTypeEnum

@export var attack_speed : float
@export var attack_range : float
@export var damage: float
@export var knockback : float
@export var statChanges : Dictionary
@export var endLag : float
@export var attackTypes : Dictionary = {
	"light" : 8,
	"heavy" : 2,
	"special" : 0
}

func generate_item(_weightedDict : Dictionary):
	var totalWeights : float = 0
	for key in _weightedDict:
		totalWeights += _weightedDict[key]
	var accumulatedweight : int = 0
	var randomWeight : float = randi_range(0, int(totalWeights)) ## Generate a random weight
	## Pick a random item based on the random weight
	for key in _weightedDict: 
		accumulatedweight += _weightedDict[key]
		if randomWeight <= accumulatedweight:
			return key
	print("NO KEY MADE CHOSEN: REPEAT")

func applyStatChanges()-> void:
	for stat in statChanges : 
		#apply stat changes to the stickman equipping the weapon
		pass

func lightHit(target:Node2D, attack_damage:float, knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used light hit")
	var hit_result = HitData.new(attack_damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func heavyHit(target:Node2D, attack_damage:float,  knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used heavy hit")
	var hit_result = HitData.new(attack_damage*1.10, knockback_direction,knockback*3.5)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func specialHit(target:Node2D, attack_damage:float,  knockback_direction:= Vector2.ZERO)-> void:
	#print(weaponName + " used special hit")
	var hit_result = HitData.new(attack_damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func hit(target:Node2D, damage_mult: float = 1.0, knockback_direction:= Vector2.ZERO)-> void:
	var attack : String = generate_item(attackTypes)
	var final_damage := damage * damage_mult

	if attack == "light" :
		lightHit(target,final_damage,knockback_direction)
	elif attack == "heavy" :
		heavyHit(target,final_damage,knockback_direction)
	elif attack == "special" :
		specialHit(target,final_damage,knockback_direction)
	else :
		pass

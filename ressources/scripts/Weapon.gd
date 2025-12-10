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
	## Calculate the total weights 
	var totalWeights : float = 0
	for key in _weightedDict:
		totalWeights += _weightedDict[key]
	var keyGenerated : bool = false
	while !keyGenerated:
		## Generate a random weight
		var randomWeight : float = randi_range(0, totalWeights)
		## Pick a random item based on the random weight
		for key in _weightedDict:
			randomWeight -= _weightedDict[key]
			if randomWeight < 0:
				keyGenerated = true
				return key
		print("NO KEY MADE CHOSEN: REPEAT")

func applyStatChanges()-> void:
	for stat in statChanges : 
		#apply stat changes to the stickman equipping the weapon
		pass

func lightHit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	print(weaponName + " used light hit")
	var hit_result = HitData.new(damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func heavyHit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	print(weaponName + " used heavy hit")
	var hit_result = HitData.new(damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func specialHit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	print(weaponName + " used special hit")
	var hit_result = HitData.new(damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func hit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	var attack : String = generate_item(attackTypes)
	if attack == "light" :
		lightHit(target,knockback_direction)
	elif attack == "heavy" :
		heavyHit(target,knockback_direction)
	elif attack == "special" :
		specialHit(target,knockback_direction)
	else :
		pass

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

func selectAttackType() -> String:
	var totalWeight : int = 0
	for type in attackTypes : 
		totalWeight += attackTypes[type]
	var roll = randi_range(0,totalWeight)
	for type in attackTypes : 
		if roll>attackTypes[type] :
			return type
	return "UNKNOWN ROLL"

func hit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	var attack : String = selectAttackType()
	if attack == "light" :
		lightHit(target,knockback_direction)
	elif attack == "heavy" :
		heavyHit(target,knockback_direction)
	elif attack == "special" :
		specialHit(target,knockback_direction)
	else :
		pass

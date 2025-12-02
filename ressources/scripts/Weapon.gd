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
@export var comboLength : int
@export var statChanges : Dictionary

func applyStatChanges()-> void:
	for stat in statChanges : 
		#apply stat changes to the stickman equipping the weapon
		pass

func lightHit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	var hit_result = HitData.new(damage, knockback_direction,knockback)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

func heavyHit(target:Node2D, knockback_direction: Vector2  = Vector2(0,0))-> void:
	var hit_result = HitData.new(damage, knockback_direction,500 + knockback*3)
	#also apply on hit passive and hediff effects once hediffs are in place
	if target.has_method("resolve_hit") :
		target.resolve_hit(hit_result)

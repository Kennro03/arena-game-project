extends Resource
class_name Weapon

enum WeaponTypeEnum { LIGHT, MEDIUM, HEAVY, SPECIAL }
var weaponType : WeaponTypeEnum
var description : String
var icon : Texture2D

var attack_speed : float
var attack_range : float
var damage: float
var knockback : float
var statChanges : Dictionary

var comboLength : int

extends Resource
class_name Pip

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, NEGATIVE, UNIQUE}
enum PipBuffType { UNIT_STAT, WEAPON_STAT}

@export var pip_rarity : Rarity = Rarity.COMMON      # pip's rarity
# type of pip inferred from the buff class
@export var buff : Buff = null               # the pip's data, StatBuff, WeaponStatBuff, etc

# extra value granted to gear per rarity tier
var value_common: float = 2.0
var value_uncommon: float = 5.0
var value_rare: float = 10.0
var value_epic: float = 15.0
var value_legendary: float = 20.0
var value_negative: float = -2.0
var value_unique: float = 0.0

func get_buff_stat_name()-> String :
	match buff.domain :
		Buff.Domain.UNIT :
			return str(Stats.BuffableStats.keys()[buff.stat_index])
		Buff.Domain.WEAPON :
			return str(Weapon.BuffableStats.keys()[buff.stat_index])
		#Buff.Domain.ARMOR :
		#	return str(ARMOR.BuffableStats.keys()[buff.stat_index])
		#Buff.Domain.PROJECTILE :
		#	return str(PROJECTILE.BuffableStats.keys()[buff.stat_index])
		_:
			return "invalid buff domain"

func _to_string() -> String:
	return "%s - %s %s %s" % [Pip.Rarity.keys()[pip_rarity],str(buff.BuffType.keys()[buff.buff_type]),str(buff.buff_amount), get_buff_stat_name()]

func get_pip_value() -> float:
	match pip_rarity:
		Rarity.COMMON: return value_common
		Rarity.UNCOMMON: return value_uncommon
		Rarity.RARE: return value_rare
		Rarity.EPIC: return value_epic
		Rarity.LEGENDARY: return value_legendary
		Rarity.NEGATIVE: return value_negative
		Rarity.UNIQUE: return value_unique
		_: return value_common

static var rarity_icons: Dictionary = {
	Rarity.COMMON : PlaceholderTexture2D.new(),
	Rarity.UNCOMMON : PlaceholderTexture2D.new(),
	Rarity.RARE : PlaceholderTexture2D.new(),
	Rarity.EPIC : PlaceholderTexture2D.new(),
	Rarity.LEGENDARY : PlaceholderTexture2D.new(),
	Rarity.NEGATIVE : PlaceholderTexture2D.new(),
	Rarity.UNIQUE : PlaceholderTexture2D.new(),
}

# small icon corresponding to rarity to quickly assert a pip's rarity when inspecting gear
func get_pip_icon(rarity: Item.Rarity) -> Texture2D:
	return rarity_icons.get(rarity, PlaceholderTexture2D.new())

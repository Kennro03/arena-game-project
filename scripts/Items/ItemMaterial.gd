extends Resource
class_name ItemMaterial

@export var material_name: String = "Debug"
@export var material_icon: Texture2D = PlaceholderTexture2D.new()
@export var material_color_palette: Texture2D

# item stats modifiers 
@export var value_multiplier: float = 1.0
@export var material_max_rarity_bonus: int = 0 # bonus to item's rarity tier, uncommon weapon with 1 bonus becomes rare

# stat modifiers specific to base weapon stats
@export_group("Weapon specific")

@export var buffs: Array[Buff] = []
@export var weapon_scaling_bonuses: Array[StatScaling] = []

# stat modifiers specific to base armor stats
@export_group("Armor specific")
#things like bonus resistance to certain damage types 

# stat modifiers specific to base accessory stats
@export_group("Accessory specific")
#things like stat bonus multiplier/bonus to the number of stat bonuses ? 
#Maybe will need a 'pip' system for stat bonuses for it to be consitent, need to work on it later.

# innate passives this material grants
# need to replace with a passive skill later or something
@export var innate_passives: Array[OnHitPassive] = []

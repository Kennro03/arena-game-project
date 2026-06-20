extends Resource
class_name ItemMaterial

enum Material_Tiers { TIER_0, TIER_1, TIER_2, TIER_3, TIER_4, SPECIAL }

@export var material_name: String = "Debug"
@export var tier: Material_Tiers = Material_Tiers.TIER_0
@export_multiline() var material_description: String = "The default material for testing purposes, no color/stat changes."
@export var material_icon: Texture2D = PlaceholderTexture2D.new()
@export var material_color_palette: Texture2D

# item stats modifiers 
@export var value_multiplier: float = 1.0
@export var material_rarity_bonus: int = 0 # bonus to item's rarity tier, uncommon weapon with 1 bonus becomes rare
@export var bonus_pips_amount: int = 0
@export var guaranteed_stat_changes: Array[Buff] = []

# innate passives this material grants
# need to replace with a passive skill later or something
@export var innate_passives: Array[OnHitPassive] = []

# stat modifiers specific to base weapon stats
@export_group("Weapon specific")
@export var weapon_scaling_bonuses: Array[StatScaling] = []

# stat modifiers specific to base armor stats
@export_group("Armor specific")

# stat modifiers specific to base accessory stats
@export_group("Accessory specific")

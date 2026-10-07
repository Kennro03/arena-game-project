extends Resource
class_name FighterGenerationConfig

@export var starting_level: int = 0 #gives enough EXP to set units at this level before giving out starting EXP
@export var starting_exp: int = 0
@export var allowed_stat_archetypes: Array[StatArchetype] = []
@export var allowed_tags: Array[String] = []
@export var allowed_weapon_types: Array[Weapon.WeaponTypeEnum] = []
@export var allowed_weapon_materials: Array[ItemMaterial] = []
@export var generated_accessories_count: int = 0
@export var allowed_accessories: Array[Accessory] = []
@export var allow_wildcard: bool = true
@export var forced_skills: Array[Skill] = [] # Active/Passive skills given to all generated fighters before level up/card draws

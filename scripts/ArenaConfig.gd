extends Resource
class_name ArenaConfig

enum TimeoutBehavior { DRAW, HIGHEST_HP, MOST_DAMAGE }
enum DrawBehavior { REDO_FIGHT, RANDOM_WINNER }
enum GearHandling { KEEP, UPGRADE_AFTER_FIGHT, REROLL_AFTER_FIGHT }
enum RoundFormat { GAUNTLET, ROUND_ROBIN, CONTINUOUS }

# fight rules
@export var max_fight_duration: float = 120.0
@export var timeout_behavior: TimeoutBehavior = TimeoutBehavior.HIGHEST_HP
@export var draw_behavior: DrawBehavior = DrawBehavior.RANDOM_WINNER

# progression
@export var progression_every_x_fight: int = 1  # every X fights per fighter
@export var exp_gained_per_prog: int = 0
@export var level_gained_per_prog: int = 0

# gear
@export var gear_handling: GearHandling = GearHandling.KEEP
# gear on generation, handled by the fighter generation scene
@export var generation_allowed_weapon_types: Array[Weapon.WeaponTypeEnum] = []
@export var generation_allowed_weapon_materials: Array[ItemMaterial] = []
@export var generation_allowed_accessories: Array[Accessory] = []
# gear on reroll, handled by the arena rules
@export var reroll_allowed_weapon_types: Array[Weapon.WeaponTypeEnum] = []
@export var reroll_allowed_weapon_materials: Array[ItemMaterial] = []
@export var reroll_allowed_accessories: Array[Accessory] = []
@export var number_of_accessories_rerolled: int = 0 #number of accessories that get reroll (randomly among owned accessories)

# simulation
@export var spectated: bool = true
@export var pause_between_rounds: bool = true
@export var simulation_speed: float = 1.0
@export var round_format: RoundFormat = RoundFormat.GAUNTLET

# meta
@export var _seed: int = 0

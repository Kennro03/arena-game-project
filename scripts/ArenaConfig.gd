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
@export var generation_allowed_weapon_bases: Array[Weapon] = []
@export var generation_allowed_weapon_materials: Array[ItemMaterial] = []
@export var generation_allowed_accessories: Array[Accessory] = []
# gear on reroll, handled by the arena rules
@export var reroll_allowed_weapon_bases: Array[Weapon] = []
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

func _to_string() -> String:
	var s := ""
	
	s += "=== ArenaConfig [seed: %d] ===\n" % _seed
	
	s += "-- Fight Rules\n"
	s += "  max_fight_duration:        %.1f s\n" % max_fight_duration
	s += "  timeout_behavior:          %s\n"     % TimeoutBehavior.keys()[timeout_behavior]
	s += "  draw_behavior:             %s\n"     % DrawBehavior.keys()[draw_behavior]
	
	s += "-- Progression\n"
	s += "  every_x_fights:            %d\n"     % progression_every_x_fight
	s += "  exp_per_prog:              %d\n"     % exp_gained_per_prog
	s += "  levels_per_prog:           %d\n"     % level_gained_per_prog
	
	s += "-- Gear\n"
	s += "  gear_handling:             %s\n"     % GearHandling.keys()[gear_handling]
	s += "  accessories_rerolled:      %d\n"     % number_of_accessories_rerolled
	
	s += _list_resources("  Weapons at generation",      generation_allowed_weapon_bases)
	s += _list_resources("  Materials at generation",    generation_allowed_weapon_materials)
	s += _list_resources("  Accessories at generation",  generation_allowed_accessories)
	s += _list_resources("  Weapons at reroll",          reroll_allowed_weapon_bases)
	s += _list_resources("  Materials at reroll",        reroll_allowed_weapon_materials)
	s += _list_resources("  Accessories at reroll",      reroll_allowed_accessories)
	
	s += "-- Simulation\n"
	s += "  spectated:                 %s\n"     % str(spectated)
	s += "  pause_between_rounds:      %s\n"     % str(pause_between_rounds)
	s += "  simulation_speed:          %.2fx\n"  % simulation_speed
	s += "  round_format:              %s\n"     % RoundFormat.keys()[round_format]
	
	return s


func _list_resources(label: String, arr: Array) -> String:
	var s := "%s: (%d)\n" % [label, arr.size()]
	for item in arr:
		s += "    - %s\n" % _res_label(item)
	return s

func _res_label(r: Resource) -> String:
	if r == null:               return "null"
	if r.resource_name != "":  return r.resource_name
	if r.resource_path != "":  return r.resource_path.get_file().get_basename()
	return str(r)

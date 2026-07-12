extends Node
class_name PlayerState

const PLAYER_TEAM := preload("res://ressources/Teams/PlayerTeam.tres")

# Economy
var gold: int = 0:
	set(value):
		var diff := value - gold
		gold = max(0, value)  # prevent negative gold
		if diff > 0:
			Events.gold_gained.emit(diff)
		elif diff < 0:
			Events.gold_lost.emit(abs(diff))
		Events.gold_changed.emit(gold)

# Units
var deployed_units: Array[BaseUnit] = []   # reference of units that are deployed on the field from team, capped by team_size
var team: Array[UnitData] = []             # units that get automatically deployed, capped by team_size
var team_size: int = 5
var reserve: Array[UnitData] = []          # bench, uncapped or larger cap, capped by reserve_size
var reserve_size: int = 20

# Inventory
var inventory: Array[Item] = []
var inventory_size: int = 50

# Run state & expedition 
var current_expedition_map: Array[Array] = []
var expedition_floors_climbed: int = 0
var expedition_last_room: Room = null
var expedition_in_progress: bool = false
var map_camera_postion : float 

var enemy_exp_bonus: int = 0  
var run_modifiers: Array = [] # To implement : persistent effects on the run

var scene_history: Array[StringName] = []
var current_scene: StringName = &""

# Meta
var run_seed: int = 0
var run_number: int = 0

# static references
static var ui_layer : CanvasLayer
static var pending_expedition : ExpeditionData = null
static var pending_battle : BattleData = null
static var pending_shop_pool : Array[Item] = []
static var pending_event : EventResource = null

@onready var gauntlets_base : Weapon = preload("uid://evw15hgtlv7a")
@onready var dagger_base : Weapon = preload("uid://dal5rgfowl103")
@onready var broadsword_base : Weapon = preload("uid://cpnr5mpvtakmp")
@onready var spear_base = preload("uid://cje1th2326lj")
@onready var greatsword_base : Weapon = preload("uid://bwlni7c3utacx")
@onready var warhammer_base : Weapon = preload("uid://cseh3bpxs7l8k")
@onready var crit_test_warhammer_base : Weapon =  preload("uid://ck34shbdlq4va")
@onready var wand_base = preload("uid://cpema83m1kpr")
@onready var foci_staff_base = preload("uid://ds6y5tv4n4hsx")
@onready var bow_base = preload("uid://cikjn1d3hom5x")

const UNCOMMONTESTSWORD = preload("uid://dlhcap3ipacyj")
const BIG_GUY_GOLD_NECKLACE = preload("uid://bcgx8j8wdnce3")

@onready var testing_pablo : UnitData = preload("uid://ps2wy7q88f5b")

func _ready() -> void:
	add_item_to_inventory(generate_weapon(gauntlets_base))
	add_item_to_inventory(generate_weapon(dagger_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(broadsword_base))
	add_item_to_inventory(generate_weapon(spear_base))
	add_item_to_inventory(generate_weapon(greatsword_base))
	add_item_to_inventory(generate_weapon(wand_base))
	add_item_to_inventory(generate_weapon(foci_staff_base))
	add_item_to_inventory(generate_weapon(bow_base))
	add_item_to_inventory(generate_weapon(warhammer_base))
	add_item_to_inventory(generate_weapon(crit_test_warhammer_base))
	add_item_to_inventory(BIG_GUY_GOLD_NECKLACE.duplicate(true))
	
	
	var piped_sword : Weapon = UNCOMMONTESTSWORD.duplicate(true)
	piped_sword.generate_pips()
	add_item_to_inventory(piped_sword)
	
	
	add_unit_to_reserve(testing_pablo.with_active_skill(preload("uid://bserc7ks8a8to")).duplicate(true)) # add a preset unitData with the knife throw skill to reserve
	add_unit_to_reserve(humanoidUnitData.new().with_active_skill(preload("uid://dhregwb73rglr")).duplicate(true))
	add_unit_to_reserve(humanoidUnitData.new().with_active_skill(preload("uid://b1y3fhvahlv34")).duplicate(true))
	add_unit_to_reserve(humanoidUnitData.new().with_active_skill(preload("uid://dli7e6s5tu673")).duplicate(true))
	add_unit_to_reserve(humanoidUnitData.new())
	add_unit_to_team(humanoidUnitData.new().with_passive_skill(preload("uid://cwenfsltyjw5l")).duplicate(true))

func add_item_to_inventory(item: Item) -> void:
	inventory.append(item)
	Events.item_added.emit(item)

func go_to_scene(scene_path: StringName) -> void:
	print("Moving to: %s (from: %s)" % [scene_path, current_scene])
	if current_scene != &"":
		scene_history.append(current_scene)
	current_scene = scene_path
	SceneLoader.load_scene(scene_path)

func return_to_previous_scene() -> void:
	if scene_history.is_empty():
		printerr("No previous scene to return to")
		return
	var target : StringName = scene_history.pop_back()
	current_scene = target
	SceneLoader.load_scene(target)

func remove_item_from_inventory(item: Item) -> void:
	if not item in inventory :
		printerr("%s not in inventory !" % [item.item_name])
		return
	inventory.erase(item)
	Events.item_removed.emit(item)

func recall_unit(unit: BaseUnit) -> void:
	if not is_instance_valid(unit):
		printerr("Cannot recall invalid unit")
		return
	if unit.unit_data == null:
		printerr("Unit has no associated UnitData: " + unit.display_name)
		return
	
	unit.save_changes_to_data() # transfer things like exp to unit_data before moving
	
	deployed_units.erase(unit) # remove from deployed
	
	# move data from team to reserve
	if unit.unit_data in team:
		team.erase(unit.unit_data)
	
	add_unit_to_reserve(unit.unit_data)
	Events.unit_recalled.emit(unit)
	unit.queue_free()

func register_deployed_unit(unit:BaseUnit) -> void:
	deployed_units.append(unit)
	unit.unit_died.connect(_on_deployed_unit_died.unbind(2).bind(unit))

func _on_deployed_unit_died(unit: BaseUnit) -> void:
	deployed_units.erase(unit)
	print("%s was downed !" % [unit.display_name])

func clear_deployed_units() -> void:
	deployed_units.clear()

func add_unit_to_team(unit: UnitData) -> void:
	if team.size() >= team_size:
		printerr("Team is full")
		return
	if unit in team:
		printerr("Unit already in team: " + unit.display_name)
		return
	unit.team = PLAYER_TEAM
	team.append(unit)
	Events.unit_added_to_team.emit(unit)

func add_unit_to_reserve(unit: UnitData) -> void:
	if reserve.size() >= reserve_size:
		printerr("Reserve is full")
		return
	if unit in reserve:
		printerr("Unit already in reserve: " + unit.display_name)
		return
	unit.team = PLAYER_TEAM
	reserve.append(unit)
	Events.unit_added_to_reserve.emit(unit)

func move_unit_to_team(unit: UnitData) -> void:
	if unit not in reserve:
		printerr("Cannot add to team: unit not in reserve")
		return
	if team.size() >= team_size:
		printerr("Team is full")
		return
	if unit in team:
		printerr("Unit already in team")
		return
	
	## Add removing unit from reserve/team
	reserve.erase(unit)
	add_unit_to_team(unit)
	Events.unit_removed_from_reserve.emit(unit)
	Events.unit_added_to_team.emit(unit)

func move_unit_to_reserve(unit: UnitData) -> void:
	if unit not in team:
		printerr("Cannot move to reserve: unit not in team")
		return
	if reserve.size() >= reserve_size:
		printerr("Reserve is full")
		return
	team.erase(unit)
	Events.unit_removed_from_team.emit(unit)
	add_unit_to_reserve(unit)

func remove_unit(unit: UnitData) -> void:
	var found : bool = false
	if unit in team :
		team.erase(unit)
		found = true
		Events.unit_removed_from_team.emit(unit)
		print("Removed %s from team" % [unit.display_name])
	if unit in reserve :
		reserve.erase(unit)
		found = true
		Events.unit_removed_from_reserve.emit(unit)
		print("Removed %s from team" % [unit.display_name])
	if not found:
		printerr("Could not remove unit, not found anywhere: " + unit.display_name)
		return
	Events.unit_removed.emit(unit)

func advance_exp_bonus(amount: int) -> void:
	enemy_exp_bonus += amount
	Events.enemy_exp_bonus_changed.emit(enemy_exp_bonus)

func sell_item(_item: Item) -> void:
	if _item not in inventory :
		return
	
	Player.gold += _item.value
	Player.remove_item_from_inventory(_item)

func get_deployed_unit(unit_data: UnitData) -> BaseUnit:
	for unit in deployed_units:
		if is_instance_valid(unit) and unit.unit_data == unit_data:
			return unit
	return null

func generate_weapon(base: Weapon, item_rarity: Item.Rarity = base.rarity, tier_weights: Dictionary = MaterialRegistry.default_tier_weights) -> Weapon:
	var generated_weapon : Weapon = base.duplicate(true)
	generated_weapon.rarity = item_rarity
	
	# roll material — tier weights can be overridden per context
	var mat : ItemMaterial = MaterialRegistry.roll_material(tier_weights)
	if mat:
		generated_weapon.weapon_material = mat
		generated_weapon.item_name = "%s %s" % [mat.material_name,generated_weapon.item_name]
		generated_weapon.rarity = clampi(
			int(generated_weapon.rarity) + mat.material_rarity_bonus, 
			0, 
			Item.Rarity.size() - 1) as Item.Rarity
		generated_weapon.guaranteed_pips_count += mat.bonus_pips_amount
	
	# roll pips after material since material can increase pip count
	generated_weapon.generate_pips()
	return generated_weapon

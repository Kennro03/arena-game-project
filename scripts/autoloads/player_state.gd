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

# Run state
var current_map: Map = null
var current_room: Room = null
var run_modifiers: Array = [] # To implement : persistent effects on the run

var previous_scene: StringName = &""
var current_scene: StringName = &""

# Meta
var run_seed: int = 0
var run_number: int = 0

@onready var testing_knife : Weapon = preload("uid://dal5rgfowl103")
@onready var testing_pablo : UnitData = preload("uid://ps2wy7q88f5b")

func _ready() -> void:
	add_item_to_inventory(testing_knife)
	add_unit_to_reserve(testing_pablo.duplicate(true))
	add_unit_to_team(testing_pablo.duplicate(true))
	add_unit_to_team(testing_pablo.duplicate(true))
	add_unit_to_team(testing_pablo.duplicate(true))
	add_unit_to_team(testing_pablo.duplicate(true))

func add_item_to_inventory(item: Item) -> void:
	inventory.append(item)
	Events.item_added.emit(item)

func go_to_scene(scene_path: StringName) -> void:
	print("Moving scenes : \nCurrent scene = %s \nPrevious scene = %s \nTarget scene = %s" % [current_scene,previous_scene,scene_path])
	previous_scene = current_scene
	current_scene = scene_path
	SceneLoader.load_scene(scene_path)

func return_to_previous_scene() -> void:
	if previous_scene == &"":
		printerr("No previous scene to return to")
		return
	go_to_scene(previous_scene)

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
	unit.unit_died.connect(_on_deployed_unit_died.unbind(1).bind(unit))

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

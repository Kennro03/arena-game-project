extends Node
class_name PlayerState

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
var team: Array[UnitData] = []        # units actively deployed, capped by team_size
var team_size: int = 5
var reserve: Array[UnitData] = []     # bench, uncapped or larger cap, capped by reserve_size
var reserve_size: int = 20

# Inventory
var inventory: Array[Item] = []
var inventory_size: int = 50

# Run state
var current_map: Map = null
var current_room: Room = null
var run_modifiers: Array = [] # To implement : persistent effects on the run

# Meta
var run_seed: int = 0
var run_number: int = 0

@onready var testing_knife : Weapon = preload("uid://dal5rgfowl103")
@onready var testing_pablo : UnitData = preload("res://ressources/Units/Pablo.tres")

func _ready() -> void:
	inventory.append(testing_knife)
	reserve.append(testing_pablo)

func add_unit_to_team(unit: UnitData) -> void:
	team.append(unit)
	Events.unit_moved_to_team.emit(unit)

func add_to_reserve(unit: UnitData) -> void:
	reserve.append(unit)
	Events.unit_recruited.emit(unit)

func add_to_inventory(item: Item) -> void:
	inventory.append(item)
	Events.item_added.emit(item)

func remove_from_inventory(item: Item) -> void:
	if not item in inventory :
		printerr("%s not in inventory !" % [item.item_name])
		return
	inventory.erase(item)
	Events.item_removed.emit(item)

func add_to_team(unit: UnitData) -> void:
	if unit not in reserve:
		printerr("Cannot add to team: unit not in reserve")
		return
	if team.size() >= team_size:
		printerr("Team is full")
		return
	if unit in team:
		printerr("Unit already in team")
		return
	team.append(unit)
	Events.unit_moved_to_team.emit(unit)

func remove_from_team(unit: UnitData) -> void:
	team.erase(unit)
	Events.unit_moved_to_reserve.emit(unit)

func remove_from_reserve(unit: UnitData) -> void:
	# also remove from team if present
	if unit in team:
		remove_from_team(unit)
	reserve.erase(unit)
	Events.unit_lost.emit(unit)

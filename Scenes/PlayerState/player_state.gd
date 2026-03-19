extends Node
class_name PlayerState

# Economy
var gold: int = 0

# Units
var team: Array[UnitData] = []        # active deployment, capped (e.g. 6)
var reserve: Array[UnitData] = []     # bench, uncapped or larger cap

# Inventory
var inventory: Array = []   # To implement : weapons, artifacts, consumables, etc.

# Run state
var current_map: Map = null
var current_room: Room = null
var run_modifiers: Array = [] # To implement : persistent effects on the run

# Meta
var run_seed: int = 0
var run_number: int = 0

extends Node2D
class_name Camp

@export var end_rest_on_action : bool = true

@onready var button_container: VBoxContainer = %ButtonContainer
@onready var rest_button: Button = %RestButton 
@onready var loot_button: Button = %LootButton
@onready var train_button: Button = %TrainButton
## Enchant and smith are options that will only be made available with certain passives/skills/items 
@onready var enchant_button: Button = %EnchantButton
@onready var smith_button: Button = %SmithButton

func _ready() -> void:
	Events.camp_entered.emit()
	enchant_button.queue_free() 
	smith_button.queue_free() 

func rest() -> void:
	# heal all units in party (both team and reserve) for a percentage (can be increased by stats and/or passives)
	for unit in Player.team + Player.reserve:
		var heal_amount := unit.stats.current_max_health * 0.3  # heal 30%
		unit.stats.health = min(unit.stats.health + heal_amount, unit.stats.current_max_health)
	Events.camp_party_rested.emit()
	if end_rest_on_action == true:
		Events.camp_exited.emit()
		Player.return_to_previous_scene()

func loot() -> void :
	# get some random loot based on expedition type, loot can be gold, weapon, accessories, armor, or any other set items
	var loot_table := LootTable.new()  # or load a specific one
	var result := loot_table.roll()
	Player.gold += result.gold
	for item in result.items:
		Player.add_item_to_inventory(item)
	Events.camp_looted.emit()
	if end_rest_on_action == true :
		Events.camp_exited.emit()
		Player.return_to_previous_scene()

func train() -> void :
	# select a few units to train, this gives them exp
	pass

func _on_rest_button_pressed() -> void:
	rest()

func _on_loot_button_pressed() -> void:
	loot()

func _on_train_button_pressed() -> void:
	train()

extends Node2D
class_name TreasureRoom

const BATTLE_REWARDS = preload("uid://chor5kpubfe5y")

@onready var outline_component: OutlineHighlighter = $OutlineComponent
@onready var chest_area_2d: Area2D = %ChestArea2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ui: CanvasLayer = %UI

@export var min_gold : int = 15
@export var max_gold : int = 30
@export var item_rolls : int = 2

var can_open_chest : bool = false
var rewards_window_ref : BattleRewards 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.ui_layer = ui
	animation_player.play("reveal_chest")

func _on_chest_area_2d_mouse_entered() -> void:
	outline_component.highlight()

func _on_chest_area_2d_mouse_exited() -> void:
	outline_component.clear_highlight()

func setup_chest() -> void:
	outline_component.outline_thickness = 2
	chest_area_2d.connect("input_event",on_chest_input_event)

func on_chest_input_event(_viewport: Node, event: InputEvent, _shape_idx: int)-> void :
	if event is InputEventMouseButton and event.pressed and !is_instance_valid(rewards_window_ref):
		process_and_spawn_loot()

func process_and_spawn_loot() -> void:
	var total_loot := LootResult.new()
	
	total_loot.gold = randi_range(min_gold, max_gold)
	if Player.pending_expedition and Player.pending_expedition.ShopItemPool :
		for i in item_rolls : 
			pass
			#total_loot.items.append(Player.pending_expedition.ShopItemPool.pick_random())
	else :
		var _debug_item_list : Array[Item] = get_debug_item_list()
		for i in item_rolls : 
			pass
			#total_loot.items.append(_debug_item_list.pick_random())
	
	var rewards_window : BattleRewards = BATTLE_REWARDS.instantiate()
	rewards_window.gold_reward = total_loot.gold
	rewards_window.item_reward = total_loot.items
	%UI.add_child(rewards_window)
	rewards_window.connect("battle_rewards_closed",on_rewards_close)
	rewards_window_ref = rewards_window

func get_debug_item_list() -> Array[Item] :
	var item_List : Array[Item] = []
	var acc_file_names := DirAccess.open("res://ressources/Items/Accessories/").get_files()
	for file_name in acc_file_names :
		if file_name.get_extension() == "tres":
			item_List.append(load("res://ressources/Items/Accessories/" + file_name))
	
	var wep_file_names := DirAccess.open("res://ressources/Items/Weapons/").get_files()
	for file_name in wep_file_names :
		if file_name.get_extension() == "tres":
			item_List.append(load("res://ressources/Items/Weapons/" + file_name))
	
	var arm_file_names := DirAccess.open("res://ressources/Items/Armors/").get_files()
	for file_name in arm_file_names :
		if file_name.get_extension() == "tres":
			item_List.append(load("res://ressources/Items/Armors/" + file_name))
	
	item_List = item_List.filter(func(item): return item.is_obtainable)
	return item_List #this returns ALL items resources for debug/testing purposes

func on_rewards_close()->void :
	Player.return_to_previous_scene()

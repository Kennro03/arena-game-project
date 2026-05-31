extends Node
class_name Shop

const SHOP_SLOT_SCENE := preload("res://Scenes/Levels/Shop/shop_slot.tscn")

@onready var ui: CanvasLayer = %UI
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var weapons_row: HBoxContainer = %WeaponsRow
@onready var refresh_button: Button = %RefreshButton
@onready var shop_ui: Control = %ShopUI
@onready var items_row: HBoxContainer = %ItemsRow
@onready var exit_shop_button: Button = %ExitShopButton
@onready var noise_rect: TextureRect = %NoiseRect

@export var refresh_cost : int = 5
@export var refresh_cost_increment : int = 3
@export var max_items_sold : int = 5
@export var max_weapons_sold : int = 5

var items_sold : int = max_items_sold
var weapons_sold : int = max_weapons_sold
var _item_list : Array[Item] = []
var _weapon_list : Array[Weapon] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.current_scene = "uid://n6ib3torqc3t"
	Player.ui_layer = ui
	
	if Player.pending_shop_pool.is_empty():
		printerr("Shop: pending_shop_pool is empty! Fallback to debug list.")
		Player.pending_shop_pool = get_debug_item_list()
	
	print("Shopping pool = [")
	for item in Player.pending_shop_pool:
		print("  %s - type: %s" % [item.item_name, item.get_script().resource_path.get_file().left(-3)])
	print("]")
	_item_list.assign(Player.pending_shop_pool.filter(func(item): return not item is Weapon))
	_weapon_list.assign(Player.pending_shop_pool.filter(func(item): return item is Weapon))
	
	refresh_button.text = "Refresh (%dg)" % [refresh_cost]
	refresh_shop()
	
	#print("Shop pool : ")
	#for i in Player.pending_shop_pool :
	#	print("\n Item : %s" % i.item_name)
	#_weapon_list.assign(Player.pending_shop_pool.filter(func(item): return item is Weapon))
	#_item_list.assign(Player.pending_shop_pool.filter(func(item): return not item is Weapon))

func _process(delta: float) -> void:
	##Placeholder background effect, will need to replace with actual shade/art
	var noise_tex := noise_rect.texture as NoiseTexture2D
	if noise_tex and noise_tex.noise is FastNoiseLite:
		var noise := noise_tex.noise as FastNoiseLite
		noise.offset.x += 1 * delta
		noise.offset.y += 10 * delta

func _on_refresh_button_pressed() -> void:
	if Player.gold >= refresh_cost :
		refresh_shop()
		Player.gold -= refresh_cost
		refresh_cost += refresh_cost_increment
		refresh_button.text = "Refresh (%dg)" % [refresh_cost]
	else : 
		animation_player.play("refresh_failed")

func refresh_shop()-> void:
	#Item list
	clear_items()
	_item_list = get_item_list()
	fill_items()
	
	#Weapon list
	clear_weapons()
	_weapon_list = get_weapon_list()
	fill_weapons()

func clear_items() -> void :
	for c in items_row.get_children() :
		c.queue_free()

func clear_weapons() -> void :
	for c in weapons_row.get_children() :
		c.queue_free()

func fill_items() -> void :
	if _item_list.is_empty():
		printerr("Shop: item list is empty, skipping fill_items")
		return
	var i : int = 0
	while i < items_sold :
		i += 1
		var _item : Accessory = _item_list.pick_random()
		var new_slot : ShopSlot = SHOP_SLOT_SCENE.instantiate()
		items_row.add_child(new_slot)
		new_slot.set_item(_item.with_attribute_buffs())
		new_slot.connect("slot_clicked",purchase_from_slot)

func fill_weapons() -> void :
	var i : int = 0
	while i < weapons_sold :
		i += 1
		var wep : Weapon = _weapon_list.pick_random()
		var new_slot : ShopSlot = SHOP_SLOT_SCENE.instantiate()
		weapons_row.add_child(new_slot)
		new_slot.set_item(wep)
		new_slot.connect("slot_clicked",purchase_from_slot)

func get_item_list() -> Array[Item] :
	var _items : Array[Item] = []
	_items.assign(Player.pending_shop_pool.filter(func(item): return not item is Weapon and item.is_obtainable))
	#print("Items = " + str(_items))
	return _items

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

func get_weapon_list() -> Array[Weapon] :
	var _weps : Array[Weapon] = []
	#var dagger := preload("uid://dal5rgfowl103")
	#var sword := preload("uid://cpnr5mpvtakmp")
	#var hammer := preload("uid://cseh3bpxs7l8k")
	#var uncommonsword := preload("uid://dlhcap3ipacyj")
	#var rarehammer := preload("uid://dbi7hcyvjnqnd")
	_weps.assign(Player.pending_shop_pool.filter(func(item): return item is Weapon))
	return _weps

func _on_exit_shop_button_pressed() -> void:
	Player.return_to_previous_scene()

func purchase_from_slot(slot:ShopSlot, _mouse_button_index : int) -> void:
	if _mouse_button_index == MOUSE_BUTTON_LEFT :
		if slot.cost <= Player.gold :
			Player.gold -= slot.cost
			Player.add_item_to_inventory(slot.item)
			#animation to grey out the slot, and make it unavailable for future purchase
		else : 
			#animation to shake the slot
			pass 

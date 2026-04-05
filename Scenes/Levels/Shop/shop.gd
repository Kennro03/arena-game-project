extends Control
class_name Shop

const SHOP_SLOT_SCENE := preload("res://Scenes/Levels/Shop/shop_slot.tscn")

@export var prototype_scene : StringName = &"" 

@onready var items_row: HBoxContainer = %ItemsRow
@onready var weapons_row: HBoxContainer = $Panel/MarginContainer/VBoxContainer/WeaponsSection/WeaponsRow
@onready var refresh_button: Button = %RefreshButton
@onready var exit_shop_button: Button = %ExitShopButton

@export var refresh_cost : int = 5
@export var refresh_cost_increment : int = 3
@export var max_items_sold : int = 5
@export var max_weapons_sold : int = 5

var items_sold : int = max_items_sold
var weapons_sold : int = max_weapons_sold
var item_list : Array[Item] = []
var weapon_list : Array[Weapon] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_button.text = "Refresh (%dg)" % [refresh_cost]
	refresh_shop()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_refresh_button_pressed() -> void:
	if Player.gold >= refresh_cost :
		refresh_shop()
		Player.gold -= refresh_cost
		refresh_cost += refresh_cost_increment
		refresh_button.text = "Refresh (%dg)" % [refresh_cost]
	else : 
		pass #add little warning animation

func refresh_shop()-> void:
	#Item list
	clear_items()
	item_list = get_item_list()
	fill_items()
	#Weapon list
	clear_weapons()
	weapon_list = get_weapon_list()
	fill_weapons()

func clear_items() -> void :
	for c in items_row.get_children() :
		c.disconnect("slot_clicked",purchase_from_slot)
		c.queue_free()

func clear_weapons() -> void :
	for c in weapons_row.get_children() :
		c.disconnect("slot_clicked",purchase_from_slot)
		c.queue_free()

func fill_items() -> void :
	var i : int = 0
	while i < items_sold :
		i += 1
		var _item : Item = item_list.pick_random()
		var new_slot : ShopSlot = SHOP_SLOT_SCENE.instantiate()
		items_row.add_child(new_slot)
		new_slot.set_item(_item)
		new_slot.connect("slot_clicked",purchase_from_slot)

func fill_weapons() -> void :
	var i : int = 0
	while i < weapons_sold :
		i += 1
		var wep : Weapon = weapon_list.pick_random()
		var new_slot : ShopSlot = SHOP_SLOT_SCENE.instantiate()
		weapons_row.add_child(new_slot)
		new_slot.set_item(wep)
		new_slot.connect("slot_clicked",purchase_from_slot)

func get_item_list() -> Array[Item] :
	var _items : Array[Item] = []
	var dagger := preload("res://ressources/Weapons/testdagger.tres")
	_items = [dagger]
	return _items

func get_weapon_list() -> Array[Weapon] :
	var _weps : Array[Weapon] = []
	var dagger := preload("res://ressources/Weapons/testdagger.tres")
	var sword := preload("res://ressources/Weapons/testsword.tres")
	var hammer := preload("res://ressources/Weapons/testhammer.tres")
	var uncommonsword := preload("res://ressources/Weapons/uncommontestsword.tres")
	var rarehammer := preload("res://ressources/Weapons/raretesthammer.tres")
	_weps = [dagger,sword,hammer,uncommonsword,rarehammer]
	return _weps

func _on_exit_shop_button_pressed() -> void:
	SceneLoader.load_scene(prototype_scene)

func purchase_from_slot(slot:ShopSlot, _mouse_button_index : int) -> void:
	if _mouse_button_index == MOUSE_BUTTON_LEFT :
		if slot.cost <= Player.gold :
			Player.gold -= slot.cost
			Player.add_to_inventory(slot.item)
			#animation to grey out the slot, and make it unavailable for future purchase
		else : 
			#animation to shake the slot
			pass 

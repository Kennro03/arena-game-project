extends Control
class_name Shop

const SHOP_SLOT_SCENE := preload("res://Scenes/Levels/Shop/shop_slot.tscn")

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
	clear_items()
	clear_weapons()
	load_weapon_list()
	fill_weapons()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_refresh_button_pressed() -> void:
	if Player.gold >= refresh_cost :
		refresh_shop()
	else : 
		pass #add little warning animation

func refresh_shop()-> void:
	pass

func clear_items() -> void :
	for c in items_row.get_children() :
		c.queue_free()

func clear_weapons() -> void :
	for c in weapons_row.get_children() :
		c.queue_free()

func fill_items() -> void :
	var i : int = 0
	while i < items_sold :
		i += 1
		

func fill_weapons() -> void :
	var i : int = 0
	while i < weapons_sold :
		i += 1
		var wep : Weapon = weapon_list.pick_random()
		var new_slot : ShopSlot = SHOP_SLOT_SCENE.instantiate()
		weapons_row.add_child(new_slot)
		new_slot.set_item(wep)

func load_weapon_list() -> void :
	var dagger := preload("res://ressources/Weapons/testdagger.tres")
	var sword := preload("res://ressources/Weapons/testsword.tres")
	var hammer := preload("res://ressources/Weapons/testhammer.tres")
	var rarehammer := preload("res://ressources/Weapons/raretesthammer.tres")
	weapon_list = [dagger,sword,hammer,rarehammer]

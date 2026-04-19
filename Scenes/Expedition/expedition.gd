extends Node2D
class_name Expedition

@export var battle_scene : StringName = &"uid://32iwvd3dtseu" 
@export var shop_scene : StringName = &"uid://n6ib3torqc3t" 
@export var event_scene : StringName = &"uid://bscmpqjoie8iu"

@onready var map: Map = %Map

func _ready() -> void:
	if map.floors_climbed == 0 :
		_start_expedition()
	Events.room_selected.connect(_on_room_selected)

func _start_expedition() -> void :
	map.generate_new_map()
	map.unlock_floor(0)

func _on_room_selected(r: Room) -> void :
	Player.clear_deployed_units()  
	match r.type :
		Room.Type.BATTLE :
			Player.go_to_scene(battle_scene)
		Room.Type.SHOP :
			Player.go_to_scene(shop_scene)
		Room.Type.EVENT :
			Player.go_to_scene(event_scene)

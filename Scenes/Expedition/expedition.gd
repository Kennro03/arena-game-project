extends Node2D
class_name Expedition

@onready var ui: CanvasLayer = %UI
@export var battle_scene : StringName = &"uid://32iwvd3dtseu" 
@export var shop_scene : StringName = &"uid://n6ib3torqc3t" 
@export var event_scene : StringName = &"uid://bscmpqjoie8iu"
@export var camp_scene : StringName = &"uid://cc2g24q57tx7l"
@export var post_expedition_scene : StringName = &"uid://hlb8w8j5gs7u"

@onready var map: Map = %Map


func _ready() -> void:
	Player.current_scene = &"uid://b2fli6g70m4oi"
	Player.ui_layer = ui
	if Player.expedition_in_progress:
		_restore_expedition()
	else:
		_start_expedition()
	if not Events.room_selected.is_connected(_on_room_selected):
		Events.room_selected.connect(_on_room_selected)

func _start_expedition() -> void :
	map.generate_new_map()
	map.unlock_floor(0)
	
	Player.current_expedition_map = map.map_data
	Player.expedition_floors_climbed = 0
	Player.expedition_last_room = null
	Player.expedition_in_progress = true

func _restore_expedition() -> void:
	# restore map from saved state
	map.map_data = Player.current_expedition_map
	map.floors_climbed = Player.expedition_floors_climbed
	map.last_room = Player.expedition_last_room
	map.create_map()
	map.camera_2d.position.y = Player.map_camera_postion
	
	# restore room availability
	if Player.expedition_last_room:
		map.unlock_next_rooms()
	else:
		map.unlock_floor(0)

func _on_room_selected(r: Room) -> void :
	# save current progress before leaving
	Events.room_selected.disconnect(_on_room_selected)
	Player.expedition_floors_climbed = map.floors_climbed
	Player.expedition_last_room = map.last_room
	Player.current_expedition_map = map.map_data
	Player.clear_deployed_units()
	
	Player.map_camera_postion = map.camera_2d.position.y
	print("ROOM SELECTED !!!!")
	match r.type :
		Room.Type.BATTLE :
			open_battle(10 + int(map.floors_climbed*3.5))
		Room.Type.SHOP :
			Player.go_to_scene.call_deferred(shop_scene)
		Room.Type.EVENT :
			open_random_event([])
		Room.Type.CAMP :
			Player.go_to_scene.call_deferred(camp_scene)

func open_battle(score: int) -> void:
	var expedition_battle_data := preload("res://ressources/BattleDatas/expedition_normal_battle.tres")
	expedition_battle_data.enemy_force = score 
	Player.pending_battle = expedition_battle_data
	Player.go_to_scene(battle_scene)

func open_random_event(event_list: Array[EventResource] = []) -> void :
	if event_list != [] :
		Player.pending_event = event_list.pick_random()
		Player.go_to_scene(event_scene)
		return
	var event_folder := "res://ressources/RandomEvents/EventList/"
	var filenames : Array[StringName] = DirAccess.get_files_at(event_folder)
	var event_ressources_list : Array[EventResource] = []
	for file_name in filenames :
		event_ressources_list.append(load(file_name))
	Player.pending_event = event_ressources_list.pick_random()
	Player.go_to_scene(event_scene)

func _end_expedition() -> void:
	Player.expedition_in_progress = false
	Player.current_expedition_map = []
	Player.expedition_floors_climbed = 0
	Player.expedition_last_room = null
	Player.go_to_scene(post_expedition_scene)

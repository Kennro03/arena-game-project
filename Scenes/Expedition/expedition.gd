extends Node2D
class_name Expedition

@export var battle_scene : StringName = &"uid://32iwvd3dtseu" 
@export var shop_scene : StringName = &"uid://n6ib3torqc3t" 
@export var event_scene : StringName = &"uid://bscmpqjoie8iu"
@export var camp_scene : StringName = &"uid://cc2g24q57tx7l"
@export var post_expedition_scene : StringName = &"uid://hlb8w8j5gs7u"

@onready var map: Map = %Map


func _ready() -> void:
	Player.current_scene = &"uid://b2fli6g70m4oi"
	if Player.expedition_in_progress:
		_restore_expedition()
	else:
		_start_expedition()
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
	Player.expedition_floors_climbed = map.floors_climbed
	Player.expedition_last_room = map.last_room
	Player.current_expedition_map = map.map_data
	Player.clear_deployed_units()
	
	Player.map_camera_postion = map.camera_2d.position.y
	match r.type :
		Room.Type.BATTLE :
			Player.go_to_scene(battle_scene)
		Room.Type.SHOP :
			Player.go_to_scene(shop_scene)
		Room.Type.EVENT :
			Player.go_to_scene(event_scene)
		Room.Type.CAMP :
			Player.go_to_scene(camp_scene)

func _end_expedition() -> void:
	Player.expedition_in_progress = false
	Player.current_expedition_map = []
	Player.expedition_floors_climbed = 0
	Player.expedition_last_room = null
	Player.go_to_scene(post_expedition_scene)

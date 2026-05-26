extends Node2D
class_name Expedition

@export var expedition_data : ExpeditionData = null

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
	
	if Player.pending_expedition :
		expedition_data = Player.pending_expedition
	
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
	
	match r.type :
		Room.Type.NORMAL_BATTLE :
			open_normal_battle(int(expedition_data.BaseEnemyScore + int(map.floors_climbed * expedition_data.FloorEnemyScoreScaling)))
		Room.Type.ELITE_BATTLE :
			open_elite_battle(int(expedition_data.BaseEnemyScore + int(map.floors_climbed * expedition_data.FloorEnemyScoreScaling)))
		Room.Type.BOSS_BATTLE :
			open_boss_battle(int(expedition_data.BaseEnemyScore + int(map.floors_climbed * expedition_data.FloorEnemyScoreScaling)))
		Room.Type.SHOP :
			open_shop()
		Room.Type.EVENT :
			open_random_event()
		Room.Type.CAMP :
			Player.go_to_scene.call_deferred(camp_scene)

func open_normal_battle(score: int) -> void:
	var _enemy_pool : Array[EnemyData] = expedition_data.EnemyPool if expedition_data.EnemyPool != [] else get_debug_enemy_pool()
	_enemy_pool = _enemy_pool.filter(func(enemy): return enemy.enemy_tier == EnemyData.EnemyTier.COMMON) # only allow normal ennemies in normal encounter
	
	var expedition_battle_data := BattleData.new()
	expedition_battle_data.enemy_force = score 
	expedition_battle_data.forced_enemies = []
	expedition_battle_data.random_enemy_pool = _enemy_pool
	expedition_battle_data.map_type = "default"     #random map generation/selection not yet implemented
	
	Player.pending_battle = expedition_battle_data
	Player.go_to_scene(battle_scene)

func open_elite_battle(score: int) -> void:
	var _enemy_pool : Array[EnemyData] = expedition_data.EnemyPool if expedition_data.EnemyPool != [] else get_debug_enemy_pool()
	
	var expedition_battle_data := BattleData.new()
	expedition_battle_data.enemy_force = score 
	expedition_battle_data.forced_enemies = []
	expedition_battle_data.random_enemy_pool = _enemy_pool
	expedition_battle_data.map_type = "default"     #random map generation/selection not yet implemented
	
	Player.pending_battle = expedition_battle_data
	Player.go_to_scene(battle_scene)

func open_boss_battle(score: int) -> void:
	var _enemy_pool : Array[EnemyData] = expedition_data.EnemyPool if expedition_data.EnemyPool != [] else get_debug_enemy_pool()
	var selected_boss : EnemyData = expedition_data.BossPool.pick_random() if expedition_data.BossPool != [] else _enemy_pool.pick_random()
	
	var expedition_battle_data := BattleData.new()
	expedition_battle_data.enemy_force = score - selected_boss.get_cost()
	expedition_battle_data.forced_enemies = [selected_boss]
	expedition_battle_data.random_enemy_pool = _enemy_pool
	expedition_battle_data.map_type = "default"     #random map generation/selection not yet implemented
	
	Player.pending_battle = expedition_battle_data
	Player.go_to_scene(battle_scene)

func open_shop() -> void:
	var item_pool : Array[Item] = expedition_data.ShopItemPool if expedition_data.ShopItemPool != [] else get_debug_shop_pool()
	Player.pending_shop_pool = item_pool
	Player.go_to_scene.call_deferred(shop_scene)

func get_debug_shop_pool() -> Array[Item]:
	var pool : Array[Item] = []
	var dir := DirAccess.open("res://ressources/Items/")
	for folder in ["Accessories", "Weapons", "Armors","Misc"]:
		dir = DirAccess.open("res://ressources/Items/" + folder + "/")
		if dir:
			for file in dir.get_files():
				if file.get_extension() == "tres":
					var item = load("res://ressources/Items/" + folder + "/" + file)
					if item.is_obtainable:
						pool.append(item)
	return pool

func get_debug_enemy_pool() -> Array[EnemyData] :
	var pool : Array[EnemyData] = []
	var dir := DirAccess.open("res://ressources/Units/enemy_data/")
	for file in dir.get_files():
		if file.get_extension() == "tres" :
			pool.append(load("res://ressources/Units/enemy_data/" + file))
	pool = pool.filter(func(enemy): return enemy.enemy_tier != enemy.EnemyTier.BOSS)
	return pool

func open_random_event() -> void :
	var event_list: Array[EventResource] = expedition_data.EventPool
	if event_list != [] :
		var res = event_list.pick_random()
		Player.pending_event = res
		Player.go_to_scene(event_scene)
		return
	
	var event_dir_address := "res://ressources/RandomEvents/EventList/"
	var event_dir := DirAccess.open(event_dir_address)
	var file_names := event_dir.get_files()
	var event_ressources_list : Array[EventResource] = []
	for file_name in file_names :
		if file_name.get_extension() == "tres":
			event_ressources_list.append(load(event_dir_address + file_name))
	var backup_res = event_ressources_list.pick_random()
	Player.pending_event = backup_res
	Player.go_to_scene(event_scene)

func _end_expedition() -> void:
	Player.expedition_in_progress = false
	Player.current_expedition_map = []
	Player.expedition_floors_climbed = 0
	Player.expedition_last_room = null
	Player.go_to_scene(post_expedition_scene)

extends Node
class_name DebugSpawner

@export var UI_node : Control 
@export var random_spawn_delay : float = 10.0

var unit: PackedScene = null # unit scene comes from UnitData.unit_scene
var default_data: UnitData = UnitData.new()
var selected_UnitData : UnitData 
var random_spawn_toggle : bool = false
var elapsed := 0.0

func _process(_delta: float) -> void:
	if random_spawn_toggle == true : 
		elapsed += _delta
		if elapsed >= random_spawn_delay :
			elapsed -= random_spawn_delay
			spawn_random(Vector2(randf_range(0.0,1152.0),randf_range(0.0,648.0)))

func _input(event):
	if event is InputEventMouseButton and event.pressed :
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered != null && hovered.get_class() != "Control" :
			#print("Mouse clicked on UI element : ", hovered.name)
			return
		
		if event.button_index == MOUSE_BUTTON_LEFT :
			print("Spawned a stickman at " + str(event.position))
			
			var data : UnitData = UI_node.inventory_module.selected_unit_data
			if data == null:
				data = humanoidUnitData.new()
				print("No unitData provided, spawning default stickman")
			spawn_from_data(event.position, data)
		
		if event.button_index == MOUSE_BUTTON_RIGHT :
			#print("Spawned a random stickman at " + str(event.position))
			spawn_random(event.position)

func _random_point_in_zone(zone: Area2D) -> Vector2:
	var shape : RectangleShape2D = zone.get_node("CollisionShape2D").shape
	var extents := shape.size / 2.0
	return zone.global_position + Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)

func spawn_from_data(pos: Vector2, data: UnitData) -> Unit:
	if data == null:
		push_error("Missing data")
		return null
	if data.unit_scene == null:
		push_error("UnitData has no unit_scene: " + data.display_name)
		return null
	
	var spawned : Unit = data.unit_scene.instantiate()
	spawned.position = pos
	spawned.apply_data(data._make_copy())
	
	for skill in data.skill_list:
		spawned.skillModule.add_skill(skill.duplicate(true))
	
	get_tree().root.add_child(spawned)
	return spawned

func spawn_random(pos: Vector2, data: UnitData = null) -> Unit:
	if data == null:
		data = humanoidUnitData.new()
	var rand_data := data.with_random_modifiers(randi() % 3 + 1 )
	
	return spawn_from_data(pos, rand_data)

func load_weapons() -> Array[Weapon]:
	var weps : Array[Weapon] = []
	for res in ResourceScan.load_all(UnitData.WEAPONS_DIR):
		if res is Weapon:
			weps.append(res)
	return weps

func _on_random_spawn_button_pressed() -> void:
	random_spawn_toggle = !random_spawn_toggle

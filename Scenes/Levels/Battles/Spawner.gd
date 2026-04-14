extends Node
class_name BattleSpawner

@export var battle_manager : Node
@export var random_spawn_delay : float = 10.0

var player_team : Team = preload("res://ressources/Teams/PlayerTeam.tres")

@onready var player_zone : Area2D = %PlayerZone
@onready var neutral_zone : Area2D = %NeutralZone
@onready var enemy_zone : Area2D = %EnemyZone

@onready var UnitLayer : Node2D = %Units
@onready var ObstaclesLayer : Node2D = %Obstacles

var unit: PackedScene = preload("res://Scenes/Units/BaseUnit/BaseUnit.tscn")
var default_data: UnitData = UnitData.new()

var selected_UnitData : UnitData 
var random_spawn_toggle : bool = false
var elapsed := 0.0

func _ready() -> void:
	Events.slot_drag_ended.connect(_on_slot_drag_ended)

func _process(_delta: float) -> void:
	if random_spawn_toggle == true : 
		elapsed += _delta
		if elapsed >= random_spawn_delay :
			elapsed -= random_spawn_delay
			spawn_random(Vector2(randf_range(0.0,get_window().GetVisibleRect().Size.x),randf_range(0.0,get_window().GetVisibleRect().Size.y)))

func _random_point_in_zone(zone: Area2D) -> Vector2:
	var col : CollisionShape2D = zone.get_node("CollisionShape2D") as CollisionShape2D
	var shape : RectangleShape2D = col.shape 
	var extents := shape.size / 2.0
	return col.global_position + Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)

func spawn_from_data(pos: Vector2, data: UnitData) -> BaseUnit:
	if data == null:
		push_error("Missing data")
		return null
	if data.unit_scene == null:
		push_error("UnitData has no unit_scene: " + data.display_name)
		return null
	
	var spawned : BaseUnit = data.unit_scene.instantiate()
	spawned.position = pos
	spawned.unit_data = data
	spawned.apply_data(data._make_copy())
	spawned.active = false
	
	for skill in data.skill_list:
		spawned.skillModule.add_skill(skill.duplicate(true))
	
	UnitLayer.add_child(spawned)
	return spawned

func spawn_random(pos: Vector2, data: UnitData = null) -> BaseUnit:
	if data == null:
		data = stickmanUnitData.new()
	var rand_data := data.with_random_modifiers(randi() % 3 + 1 )
	return spawn_from_data(pos, rand_data)

func load_weapons() -> Array[Weapon]:
	var weps : Array[Weapon] = []
	for file_name in DirAccess.get_files_at("res://ressources/Weapons/"):
		if (file_name.get_extension() == "tres"):
			weps.append(load("res://ressources/Weapons/"+file_name))
	return weps

func _on_random_spawn_button_pressed() -> void:
	random_spawn_toggle = !random_spawn_toggle

func _on_slot_drag_ended(slot: Slot, world_pos: Vector2) -> void:
	if slot is UnitSlot and slot._unit_data != null:
		_try_deploy_unit(slot._unit_data, world_pos)
	if slot is ItemSlot and slot.item != null :
		_try_equip_item(slot.item,world_pos)

func _get_unit_at_position(world_pos: Vector2) -> BaseUnit :
	var space := get_viewport().world_2d.direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := space.intersect_point(query)
	for result in results:
		var parent : Node = result.collider.get_parent()
		if parent is BaseUnit:
			return parent
	return null

func _try_equip_item(item: Item, world_pos: Vector2) -> void:
	# check if dropped on a deployed unit
	var target_unit := _get_unit_at_position(world_pos)
	if target_unit and target_unit in Player.deployed_units :
		if item is Weapon and target_unit.weapon.item_id != target_unit.default_weapon.item_id :
			Player.add_item_to_inventory(target_unit.weapon)
		if item is Armor and target_unit.armor != null :
			Player.add_item_to_inventory(target_unit.armor)
		if item is Accessory and target_unit.accessories.size() == target_unit.stats.current_accessory_limit :
			return
			## !!! Need special logic to determine which accessories to replace
		target_unit.equip(item)
		Player.remove_item_from_inventory(item)

func _try_deploy_unit(data: UnitData, world_pos: Vector2) -> void:
	#if not _is_in_player_zone(world_pos):
		#return
	
	if battle_manager.state != battle_manager.LevelState.SPAWNING :
		Events.unit_deployment_failed.emit("Cannot deploy outside of deployment phase")
		return
	
	if Player.team.size() >= Player.team_size:
		Events.unit_deployment_failed.emit("Team is full")
		return
	
	if is_in_zone(player_zone,get_world_mouse_position()) != true :
		printerr("Can't deploy unit outside of player zone")
		Events.unit_deployment_failed.emit("Cursor not in player zone")
		return
	
	Player.move_unit_to_team(data)
	
	var deployed_unit := spawn_from_data(world_pos, data)
	Player.register_deployed_unit(deployed_unit)
	battle_manager.player_units_alive.append(deployed_unit)
	deployed_unit.stats.health_depleted.connect(battle_manager._on_player_unit_died.bind(deployed_unit))
	
	Events.unit_deployed.emit(data)

func is_in_zone(zone: Area2D, world_pos: Vector2) -> bool:
	var col := zone.get_node("CollisionShape2D") as CollisionShape2D
	if col == null:
		return false
	var shape := col.shape as RectangleShape2D
	if shape == null:
		printerr("no shape defined for zone " + str(zone))
		return false
	var rect := Rect2(col.global_position - shape.size / 2.0, shape.size)
	return rect.has_point(world_pos)

func get_world_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

func is_mouse_in_player_zone() -> bool:
	return is_in_zone(player_zone, get_world_mouse_position())

func is_mouse_in_neutral_zone() -> bool:
	return is_in_zone(neutral_zone, get_world_mouse_position())

func is_mouse_in_ennemy_zone() -> bool:
	return is_in_zone(enemy_zone, get_world_mouse_position())

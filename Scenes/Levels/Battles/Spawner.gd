extends Node
class_name EncounterSpawner

@export var random_spawn_delay : float = 10.0

var player_team : Team = preload("res://ressources/Teams/PlayerTeam.tres")
@onready var PlayerSpawnZone : Area2D = %PlayerZone

@onready var NeutralSpawnZone : Area2D = %NeutralZone
@onready var UnitLayer : Node2D = %Units
@onready var ObstaclesLayer : Node2D = %Obstacles
@onready var Manager : BattleManager = get_parent()

var unit: PackedScene = preload("res://Scenes/Units/BaseUnit/BaseUnit.tscn")
var default_data: UnitData = UnitData.new()

var selected_UnitData : UnitData 
var random_spawn_toggle : bool = false
var elapsed := 0.0

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

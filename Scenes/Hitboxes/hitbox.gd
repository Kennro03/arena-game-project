extends Area2D
signal hitbox_finished(targets: Array)

#Caster and targets
var caster : Node2D
var target_list : Array[Node2D]
#Duration, filter and movement
@export var duration: float = 1.0
@export var group_filter: String = "Hurtbox"
@export var move_over_time: bool = false
@export var velocity: Vector2 = Vector2.ZERO 
#Growth (using scale)
@export var grow_over_time : bool = false
@export var scale_growth_rate : float = 1.0
var growth_min_scale : float = 0.25
var growth_max_scale : float = 4.0
#Follow target
@export var follow_target : NodePath
@export var follow_offset : Vector2 = Vector2.ZERO
var _target_ref : Node2D = null
#Shape
@export var shape: Shape2D = CapsuleShape2D.new()
var radius: float 
var size: Vector2
var height: float
var point_A: Vector2 
var point_B: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_shape_and_dimensions()
	if follow_target != NodePath() :
		_target_ref = get_node_or_null(follow_target)
	
	
	target_list = get_stickmen_in_area(group_filter)
	await get_tree().create_timer(duration).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _target_ref and is_instance_valid(_target_ref) :
		global_position = _target_ref.global_position + follow_offset
	
	if move_over_time : 
		position += velocity * delta
	pass

func set_shape_and_dimensions() -> void:
	if shape:
		$CollisionShape2D.shape = shape
	if shape is CapsuleShape2D :
		$CollisionShape2D.radius = radius
		$CollisionShape2D.height = height
	elif shape is RectangleShape2D :
		$CollisionShape2D.size = size
	elif shape is CircleShape2D :
		$CollisionShape2D.radius = radius
	elif shape is SegmentShape2D :
		$CollisionShape2D.A = point_A
		$CollisionShape2D.B = point_B
	else :
		printerr("Unsupported shape!")

func get_overlapping_areas_in_area(areagroupname : String = "Hurtbox") -> Array:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(areagroupname) :
			results.append(overlap)
	return results

func get_stickmen_in_area(areagroupname : String = "Hurtbox") -> Array:
	var results: Array = []
	for overlap in self.get_overlapping_areas() :
		if overlap.is_in_group(areagroupname) :
			results.append(overlap.owner)
	return results

extends Area2D

@export var duration: float = 0.2
@export var group_filter: String = "Hurtbox"

@export var shape: Shape2D = CapsuleShape2D.new()
@export var radius: float 
@export var size: Vector2
@export var height: float
@export var point_A: Vector2 
@export var point_B: Vector2

var caster : Node2D
var target_list : Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_shape_and_dimensions()
	target_list = get_stickmen_in_area(group_filter)
	await get_tree().create_timer(duration).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

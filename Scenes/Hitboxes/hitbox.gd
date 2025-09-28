extends Area2D
signal hitbox_started(targets: Array[Node2D])
signal hitbox_finished(targets: Array[Node2D])
#Caster and targets
var caster : Node2D
var target_list : Array[Node2D]

#Shape
@export var shape: Shape2D 
@export var radius: float = 30.0
@export var size: Vector2 = Vector2(10.0,10.0)
@export var height: float = 50.0
@export var point_A: Vector2 = Vector2(10.0,10.0)
@export var point_B: Vector2 = Vector2(50.0,50.0)
#Duration, filter and movement
@export var duration: float = 1000.0
var lifetime_elapsed: float = 0.0
@export var group_filter: String = "Hurtbox"
@export var move_over_time: bool = false
@export var velocity: Vector2 = Vector2.ZERO 
#Growth (using scale)
@export var grow_over_time : bool = false
@export var growth_curve: Curve
var growth_min_scale : float = 0.25
var growth_max_scale : float = 4.0
#Follow target
@export var follow_target : NodePath
@export var follow_offset : Vector2 = Vector2.ZERO
var _follow_target_ref : Node2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_shape_and_dimensions()
	if follow_target != NodePath() and !follow_target.is_empty() :
		print("Following target : " + str(follow_target))
		_follow_target_ref = get_node_or_null(follow_target)
	
	#target_list = get_stickmen_in_area()
	emit_signal("hitbox_started", get_stickmen_in_area())
	await get_tree().create_timer(duration).timeout
	queue_free()
	emit_signal("hitbox_finished", target_list.filter(is_instance_valid))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Track lifetime
	lifetime_elapsed += delta
	
	# Clean dead references
	target_list = target_list.filter(func(t): return is_instance_valid(t))
	
	# Follow target
	if follow_target :
		check_follow_target()
		if is_instance_valid(_follow_target_ref) :
			global_position = _follow_target_ref.global_position + follow_offset
	
	# Move hitbox
	if move_over_time : 
		global_position += velocity * delta
	
	# Grow/Shrink hitbox
	growth()
	
	#print("Target list : " + str(target_list))

func set_shape_and_dimensions() -> void:
	if shape: 
		$CollisionShape2D.shape = shape 
		if shape is CapsuleShape2D : 
			$CollisionShape2D.shape.radius = radius 
			$CollisionShape2D.shape.height = height 
		elif shape is RectangleShape2D : 
			$CollisionShape2D.shape.size = size 
		elif shape is CircleShape2D : 
			$CollisionShape2D.shape.radius = radius 
		elif shape is SegmentShape2D : 
			$CollisionShape2D.shape.A = point_A 
			$CollisionShape2D.shape.B = point_B 
		else : printerr("Unsupported shape!") 
	else : printerr(str(self) + " : has no shape!")

func get_overlapping_areas_in_area() -> Array[Area2D]:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(group_filter) :
			results.append(overlap)
	return results

func get_stickmen_in_area() -> Array[Node2D]:
	var results: Array[Node2D] = []
	for overlap in self.get_overlapping_areas() :
		if overlap.is_in_group(group_filter) :
			results.append(overlap.owner)
	return results

func attach_to(node: Node2D, offset: Vector2 = Vector2.ZERO):
	node.add_child(self)
	position = offset

func growth() -> void: 
	if grow_over_time and growth_curve:
		var t = (lifetime_elapsed / duration)
		scale = Vector2.ONE * growth_curve.sample(t)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(group_filter) and !target_list.has(area.owner)  :
		target_list.append(area.owner)
		#print("Entered hitbox : " + str(area.owner))

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group(group_filter) and target_list.has(area.owner)  :
		target_list.erase(area.owner)
		#print("Exited hitbox : " + str(area.owner))

func get_targets() -> Array[Node2D]:
	return target_list.filter(is_instance_valid)

func check_follow_target() -> void : 
	if !is_instance_valid(_follow_target_ref) :
		printerr(str(self) + " : followed Node gone!")
		follow_target = NodePath()
		_follow_target_ref = null
		queue_free()

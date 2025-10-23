extends Area2D
signal hitbox_started(target_list: Array[Node2D])
signal hitbox_finished(target_list: Array[Node2D])

#Essentials
@export var shape: Shape2D 
@export var duration: float = 100.0 #in seconds
@export var group_filter: String = "Hurtbox"
@export var origin_position : Vector2
@export var origin_rotation : float

#Movement
@export var move_over_time: bool = false
@export var velocity: Vector2 = Vector2.ZERO 

#Follow target
@export var follow_target : NodePath
@export var follow_offset : Vector2 = Vector2.ZERO

#Growth
@export var grow_over_time : bool = false
@export var growth_curve: Curve

#Internals
var caster : Node2D
var target_list : Array[Node2D]
var lifetime_elapsed: float = 0.0
var _follow_target_ref : Node2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_properties()
	if follow_target != NodePath() and !follow_target.is_empty() :
		#print("Following target : " + str(follow_target))
		_follow_target_ref = get_node_or_null(follow_target)
	
	await get_tree().process_frame
	emit_signal("hitbox_started", get_units_in_area())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Track lifetime and clean dead references
	lifetime_elapsed += delta
	target_list = target_list.filter(func(t): return is_instance_valid(t))
	
	if follow_target and move_over_time :
		printerr(str(self) +" Can't follow AND move over time! Disabling movement.")
		move_over_time = false
	elif follow_target :
		check_follow_target()
		if is_instance_valid(_follow_target_ref) :
			global_position = _follow_target_ref.global_position + follow_offset
	elif move_over_time : 
		global_position += velocity * delta
	growth()
	
	if lifetime_elapsed >= duration :
		#print("Hitbox lifetime finished, despawning")
		emit_signal("hitbox_finished")
		queue_free()
	#print("Target list : " + str(target_list))

func set_properties() -> void:
	if shape: 
		$CollisionShape2D.shape = shape 
	else : printerr(str(self) + " : has no shape!")
	
	if origin_position != Vector2.ZERO:
		global_position = origin_position
	if origin_rotation != 0.0:
		global_rotation = deg_to_rad(origin_rotation) 


func get_overlapping_areas_in_area() -> Array[Area2D]:
	var results: Array = []
	for overlap in self.get_overlapping_areas():
		if overlap.is_in_group(group_filter) :
			results.append(overlap)
	return results

func get_units_in_area() -> Array[Node2D]:
	var results: Array[Node2D] = []
	for overlap in self.get_overlapping_areas() :
		if overlap.is_in_group(group_filter) :
			results.append(overlap.owner)
	return results

func attach_to(node: Node2D, offset: Vector2 = Vector2.ZERO):
	node.add_child(self)
	position = offset

func growth() -> void: 
	if grow_over_time and growth_curve and growth_curve.get_point_count() > 1:
		var t = clamp(lifetime_elapsed / duration, 0.0, 1.0)
		scale = Vector2.ONE * growth_curve.sample(t)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(group_filter) :
		target_list.append(area.owner)
		#print("Entered hitbox : " + str(area.owner))

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group(group_filter) :
		target_list.erase(area.owner)
		#print("Exited hitbox : " + str(area.owner))

func get_targets() -> Array[Node2D]:
	return target_list.filter(is_instance_valid)

func check_follow_target() -> void : 
	if !is_instance_valid(_follow_target_ref) :
		#printerr(str(self) + " : followed Node gone!")
		follow_target = NodePath()
		_follow_target_ref = null
		queue_free()

func set_origin(pos: Vector2, rot: float = 0.0) -> void:
	self.global_position = pos 
	self.rotation  = rot

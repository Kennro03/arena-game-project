extends Node2D
class_name LingeringAreaEffect

@export var shape: AreaVisual.AreaShape = AreaVisual.AreaShape.CIRCLE
@export var size: Vector2 = Vector2(120, 80)
@export var fill_color: Color = Color(0.2, 0.8, 0.2, 0.3)
@export var border_color: Color = Color(0.2, 0.8, 0.2, 0.8)
@export var emit_particles: bool = true

@export var duration: float = 3.0          # -1 = permanent
@export var tick_interval: float = 1.0
@export var effects_per_tick: Array[SkillEffect] = []
@export var affect_allies: bool = true
@export var affect_enemies: bool = false

@onready var area_visual: AreaVisual = %AreaVisual
@onready var detection_area: Area2D = %DetectionArea
@onready var collision_shape: CollisionShape2D = %CollisionShape

var _caster: BaseUnit = null
var _elapsed: float = 0.0
var _tick_timer: float = 0.0

func _ready() -> void:
	# set up collision shape to match visual size
	match shape:
		AreaVisual.AreaShape.CIRCLE, AreaVisual.AreaShape.RING:
			var circle := CircleShape2D.new()
			circle.radius = (size.x + size.y) / 4.0  # average of both half-radii
			collision_shape.shape = circle
			collision_shape.rotation_degrees = 0.0
			area_visual.rotation_degrees = 0.0
		
		AreaVisual.AreaShape.RECTANGLE, AreaVisual.AreaShape.ROUNDED_RECTANGLE:
			var rect := RectangleShape2D.new()
			rect.size = size
			collision_shape.shape = rect
			collision_shape.rotation_degrees = 0.0
			area_visual.rotation_degrees = 0.0
		
		AreaVisual.AreaShape.DIAMOND:
			# diamond fits inside a circle of half the smallest dimension
			var circle := CircleShape2D.new()
			circle.radius = min(size.x, size.y) / 2.0
			collision_shape.shape = circle
			collision_shape.rotation_degrees = 0.0
			area_visual.rotation_degrees = 0.0
		
		AreaVisual.AreaShape.CAPSULE:
			var capsule := CapsuleShape2D.new()
			capsule.radius = size.x/2
			capsule.height = size.y
			collision_shape.shape = capsule
			collision_shape.rotation_degrees = 90.0
			area_visual.rotation_degrees = 90.0
	
	area_visual.setup(shape, size, fill_color, border_color, emit_particles)

func setup(caster: BaseUnit) -> void:
	_caster = caster

func _process(delta: float) -> void:
	if duration > 0.0:
		_elapsed += delta
		if _elapsed >= duration:
			queue_free()
			return
	
	_tick_timer += delta
	if _tick_timer >= tick_interval:
		_tick_timer = 0.0
		_apply_tick()

func _apply_tick() -> void:
	#print("area ticking")
	for body in detection_area.get_overlapping_areas():
		var unit := body.get_parent() as BaseUnit
		if unit == null or not is_instance_valid(unit):
			continue
		
		var is_ally := _caster != null and _caster.check_if_ally(unit)
		if (is_ally and affect_allies) or (not is_ally and affect_enemies):
			if effects_per_tick.is_empty():
				printerr("Not effects for lingering area !")
				return
			else:
				var context := {"target": unit, "caster": _caster}
				for effect in effects_per_tick:
					effect.apply(unit, context)

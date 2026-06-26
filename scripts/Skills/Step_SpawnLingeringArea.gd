extends CastStep
class_name Step_SpawnLingeringArea

const AREA_SCENE := preload("uid://vnoq55ghhjy8")

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

@export var follow_caster: bool = false

func execute(caster: BaseUnit, context: Dictionary, next: Callable) -> void:
	var area := AREA_SCENE.instantiate() as LingeringAreaEffect
	area.shape = shape
	area.size = size
	area.duration = duration
	area.tick_interval = tick_interval
	area.fill_color = fill_color
	area.border_color = border_color
	area.emit_particles = emit_particles
	area.affect_allies = affect_allies
	area.affect_enemies = affect_enemies
	area.effects_per_tick = effects_per_tick
	
	caster.get_tree().root.add_child(area)
	area.setup(caster)
	
	if follow_caster:
		caster.get_tree().root.remove_child(area)
		caster.add_child(area)
		area.position = Vector2.ZERO
	else:
		var target := context.get("target") as BaseUnit
		area.global_position = target.global_position if target else caster.global_position
	
	next.call()

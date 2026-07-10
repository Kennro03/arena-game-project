extends CastStep
class_name Step_SpawnLingeringArea

const AREA_SCENE := preload("uid://vnoq55ghhjy8")

@export_group("Function details")
@export var shape: AreaVisual.AreaShape = AreaVisual.AreaShape.CIRCLE
@export var size: Vector2 = Vector2(120, 80)
@export var duration: float = 3.0          # -1 = permanent
@export var tick_interval: float = 1.0
@export var effects_per_tick: Array[SkillEffect] = []
@export var affect_allies: bool = true
@export var affect_enemies: bool = false
@export var follow_target: bool = false
@export var follow_speed: float = 0.0

@export_group("Visuals")
@export var draw_area: bool = true
@export var fill_color: Color = Color(0.712, 0.712, 0.712, 0.302)
@export var border_color: Color = Color(0.337, 0.337, 0.337, 0.8)
@export var particle_scene: PackedScene = null
@export var area_sprite: Texture2D = null
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_color_modulation : Color = Color(1,1,1,1)

func execute(caster: BaseUnit, context: Dictionary, next: Callable) -> void:
	var area : LingeringAreaEffect = AREA_SCENE.instantiate()
	area.shape = shape
	area.size = size
	area.duration = duration
	area.tick_interval = tick_interval
	area.draw_area = draw_area
	area.fill_color = fill_color
	area.border_color = border_color
	area.particle_scene = particle_scene
	area.affect_allies = affect_allies
	area.affect_enemies = affect_enemies
	area.effects_per_tick = effects_per_tick
	area.area_sprite = area_sprite
	area.sprite_scale = sprite_scale
	area.sprite_color_modulation = sprite_color_modulation
	
	var target := context.get("target") as BaseUnit
	
	if follow_target : 
		area.follows_target = true
		area._target = target
		area.follow_speed = follow_speed
	
	caster.get_tree().root.add_child(area) # may need to set it inside the entities layer later
	area.setup(caster)
	
	area.global_position = target.global_position if target else caster.global_position
	area._target = target
	
	next.call()

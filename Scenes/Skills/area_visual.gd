extends Node2D
class_name AreaVisual

@onready var color_rect: ColorRect = %ColorRect
@onready var particles_emitter: GPUParticles2D = %ParticlesEmitter
@onready var area_sprite: AnimatedSprite2D = %AreaSprite

enum AreaShape { CIRCLE, RECTANGLE, ROUNDED_RECTANGLE, DIAMOND, RING, CAPSULE }

func setup(shape: AreaShape, 
		size: Vector2, 
		draw_area_bool: bool,
		fill_color: Color, 
		border_color: Color, 
		particle_scene: PackedScene = null, 
		sprite: Texture2D = null, 
		sprite_scale: Vector2 = Vector2.ONE,
		sprite_color_modulation : Color = Color(1,1,1,1)) -> void:
	
	color_rect.size = size
	color_rect.position = -size / 2.0  # center on parent
	
	if draw_area_bool :
		color_rect.visible = true
		var mat : ShaderMaterial = color_rect.material.duplicate(true) 
		color_rect.material = mat  
		mat.set_shader_parameter("shape_type", int(shape))
		mat.set_shader_parameter("rect_size", size)
		mat.set_shader_parameter("fill_color", fill_color)
		mat.set_shader_parameter("border_color", border_color)
	
	if particle_scene != null:
		particles_emitter.visible = true
		_setup_particles(size)
		add_child(particle_scene.instantiate().duplicate(true))
	
	if sprite:
		area_sprite.sprite_frames.add_frame("default",sprite)
		area_sprite.scale = sprite_scale
		area_sprite.visible = true
		area_sprite.modulate = sprite_color_modulation
	else:
		area_sprite.visible = false

func _setup_particles(area_size: Vector2) -> void:
	# confine particles to the ellipse area
	var emission : ParticleProcessMaterial = particles_emitter.process_material
	particles_emitter.process_material = emission  
	emission.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	emission.emission_sphere_radius = min(area_size.x, area_size.y) / 2.0

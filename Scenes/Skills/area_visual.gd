extends Node2D
class_name AreaVisual

@onready var color_rect: ColorRect = %ColorRect
@onready var particles_emitter: GPUParticles2D = %ParticlesEmitter

enum AreaShape { CIRCLE, RECTANGLE, ROUNDED_RECTANGLE, DIAMOND, RING, CAPSULE }

func setup(shape: AreaShape, size: Vector2, fill_color: Color, border_color: Color, emit_particles: bool = false) -> void:
	color_rect.size = size
	color_rect.position = -size / 2.0  # center on parent
	
	var mat := color_rect.material as ShaderMaterial
	mat.set_shader_parameter("shape_type", int(shape))
	mat.set_shader_parameter("rect_size", size)
	mat.set_shader_parameter("fill_color", fill_color)
	mat.set_shader_parameter("border_color", border_color)
	
	particles_emitter.visible = emit_particles
	if emit_particles:
		_setup_particles(size)

func _setup_particles(area_size: Vector2) -> void:
	# confine particles to the ellipse area
	var emission := particles_emitter.process_material as ParticleProcessMaterial
	emission.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	emission.emission_sphere_radius = min(area_size.x, area_size.y) / 2.0

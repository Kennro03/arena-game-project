extends Node2D
class_name ParticleModule

@export var hit_effect_scene: PackedScene  
var block_particle : PackedScene = preload("res://Scenes/VFX/block_particles_2d.tscn")
var parry_particle : PackedScene = preload("res://Scenes/VFX/parry_particles_2d.tscn")
var hit_particle : PackedScene = preload("res://Scenes/VFX/hit_particles_2d.tscn")
var level_up_particle : PackedScene = preload("res://Scenes/VFX/level_up_particles_2d.tscn")

@onready var DamagePopupMarker : Marker2D = $DamagePopupMarker

var _active_particles := {}

func _spawn(scene: PackedScene, hit_data: HitData = null) -> Node2D:
	if scene == null:
		push_warning("ParticleModule: tried to spawn a null scene.")
		return null
	var inst := scene.instantiate() 
	add_child(inst)
	print("Added child " + str(inst))
	if hit_data != null and inst.has_method("setup"):
		inst.setup(hit_data)
	if inst is GPUParticles2D:
		(inst as GPUParticles2D).emitting = true
	return inst

func spawn_particle(particle_scene : PackedScene) -> void :
	var inst = particle_scene.instantiate()
	add_child(inst)
	inst.emitting = true
	if not _active_particles.has(particle_scene):
		_active_particles[particle_scene] = []
	_active_particles[particle_scene].append(inst)

func remove_particle(particle_scene : PackedScene) -> void :
	if not _active_particles.has(particle_scene):
		return
	var instances: Array = _active_particles[particle_scene]
	if instances.size() > 0:
		instances[0].queue_free()
		instances.remove_at(0)
	if instances.is_empty():
		_active_particles.erase(particle_scene)

func emit_block_particles(hit_data: HitData = null) -> void:
	_spawn(block_particle, hit_data)

func emit_parry_particles(hit_data: HitData = null) -> void:
	_spawn(parry_particle, hit_data)

func emit_hit_particles(hit_data: HitData = null) -> void:
	_spawn(hit_effect_scene, hit_data)

func emit_level_up_particles() -> void:
	_spawn(level_up_particle)

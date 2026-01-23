extends Node2D

var block_particle : PackedScene = preload("res://Scenes/VFX/block_particles_2d.tscn")
var parry_particle : PackedScene = preload("res://Scenes/VFX/parry_particles_2d.tscn")
var hit_particle : PackedScene = preload("res://Scenes/VFX/hit_particles_2d.tscn")

var active_particles := {}

func spawn_particle(particle_scene : PackedScene) -> void :
	var inst = particle_scene.instantiate().duplicate()
	self.add_child(inst)
	inst.emitting = true
	inst.tree_exited.connect(func(): active_particles.erase(particle_scene))
	active_particles[particle_scene] = inst
	#print("Added child to particle module : " + str(inst))
	#print("Active particles list = " + str(active_particles))

func remove_particle(particle_scene : PackedScene) -> void :
	if active_particles.has(particle_scene):
		active_particles[particle_scene].queue_free()
		active_particles.erase(particle_scene)

func emit_block_particles(_hit_data : HitData = null)->void:
	var inst = block_particle.instantiate().duplicate()
	if _hit_data : 
		#apply changed depending on hit data here
		pass
	self.add_child(inst)
	inst.emitting = true

func emit_parry_particles(_hit_data : HitData = null)->void:
	var inst = parry_particle.instantiate().duplicate()
	if _hit_data : 
		#apply changed depending on hit data here
		pass
	self.add_child(inst)
	inst.emitting = true

func emit_hit_particles(_hit_data : HitData = null)->void:
	var inst = hit_particle.instantiate().duplicate()
	if _hit_data : 
		#apply changed depending on hit data here
		pass
	self.add_child(inst)
	inst.emitting = true

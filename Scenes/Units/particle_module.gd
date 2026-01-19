extends Node2D

var block_particle : PackedScene = preload("res://Scenes/VFX/block_particles_2d.tscn")
var parry_particle : PackedScene = preload("res://Scenes/VFX/parry_particles_2d.tscn")
var hit_particle : PackedScene = preload("res://Scenes/VFX/hit_particles_2d.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_particle(particle_scene : PackedScene) -> void :
	var inst = particle_scene.instantiate().duplicate()
	self.add_child(inst)
	inst.emitting = true

func emit_block_particles()->void:
	spawn_particle(block_particle)

func emit_parry_particles()->void:
	spawn_particle(parry_particle)

func emit_hit_particles()->void:
	spawn_particle(hit_particle)

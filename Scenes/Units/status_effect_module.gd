extends Node2D

@export var StatusEffects : Array[StatusEffect] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(StatusEffects.size() - 1, -1, -1):
		if StatusEffects[i].update(owner, delta):
			StatusEffects.remove_at(i)

func apply_status_effect(new_status : StatusEffect) -> void:
	for effect in StatusEffects:
		if effect.status_ID == new_status.status_ID:
			effect.add_stack(owner, new_status.stacks_affliction)
			if effect.refresh_on_application:
				effect.refresh_duration()
			return

	var inst := new_status.duplicate(true)
	StatusEffects.append(inst)
	inst.on_apply(owner, inst)
	inst.connect("emit_particle", spawn_particle)

func remove_status_effect(status : StatusEffect) -> void:
	if StatusEffects.has(status) :
		var index = StatusEffects.find(status)
		StatusEffects[index].disconnect("emit_particle",spawn_particle)
		StatusEffects.erase(status)

func cleanse_status_effects() -> void : 
	StatusEffects.clear()

func spawn_particle(particle_scene : PackedScene) -> void:
	if particle_scene != null :
		%ParticleModule.spawn_particle(particle_scene)
	else :
		printerr("No particle scene!")

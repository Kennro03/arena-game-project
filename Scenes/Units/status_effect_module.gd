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
	var status_inst = new_status.duplicate(true)
	if StatusEffects == [] :
		StatusEffects.append(status_inst)
		StatusEffects[0].on_apply(owner, status_inst)
		StatusEffects[0].connect("emit_particle",spawn_particle)
	else : 
		for effect in StatusEffects :
			if effect.status_ID == status_inst.status_ID :
				var index := StatusEffects.find(status_inst)
				StatusEffects[index].add_stack(owner, status_inst.stacks_affliction)
				if StatusEffects[index].refresh_on_application == true :
					StatusEffects[index].refresh_duration()
			else : 
				StatusEffects.append(status_inst)
				status_inst.on_apply(owner, status_inst)
				StatusEffects[-1].connect("emit_particle",spawn_particle)

func remove_status_effect(status : StatusEffect) -> void:
	if StatusEffects.has(status) :
		StatusEffects.erase(status)

func cleanse_status_effects() -> void : 
	StatusEffects.clear()

func spawn_particle(particle_scene : PackedScene) -> void:
	if particle_scene != null :
		%ParticleModule.spawn_particle(particle_scene)
	else :
		printerr("No particle scene!")

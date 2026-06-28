extends Node2D
class_name StatusEffectModule

@warning_ignore("unused_signal")
signal effects_changed(statusEffectsList)
signal effect_applied_with_id(effect: StatusEffect)

@export var statusEffectsList : Array[StatusEffect] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(statusEffectsList.size() - 1, -1, -1):
		if statusEffectsList[i].update(owner, delta):
			statusEffectsList.remove_at(i)

func apply_status_effect(new_status : StatusEffect) -> void:
	for effect in statusEffectsList:
		if effect.status_ID == new_status.status_ID:
			effect.add_stack(owner, new_status.stacks_affliction)
			if effect.refresh_on_application:
				effect.refresh_duration()
			return
	var inst := new_status.duplicate(true)
	statusEffectsList.append(inst)
	
	if inst.has_signal("emit_particle") : 
		#print("connecting emit_particle signal")
		inst.connect("emit_particle", spawn_particle)
	if inst.has_signal("stop_particle") :
		#print("connecting stop_particle signal")
		inst.connect("stop_particle", remove_particle)
	
	inst.on_apply(owner, inst)
	effect_applied_with_id.emit(inst)

func remove_status_effect(status : StatusEffect) -> void:
	if statusEffectsList.has(status) and status.has_signal("emit_particle") and status.is_connected("emit_particle", spawn_particle) :
		var index = statusEffectsList.find(status)
		statusEffectsList[index].disconnect("emit_particle",spawn_particle)
		statusEffectsList.erase(status)

func cleanse_status_effects() -> void : 
	statusEffectsList.clear()

func spawn_particle(particle_scene : PackedScene) -> void:
	if particle_scene != null :
		#print("Spawning particle " + str(particle_scene))
		%ParticleModule.spawn_particle(particle_scene)
	else :
		printerr("No particle scene!")

func remove_particle(particle_scene : PackedScene) -> void:
	if particle_scene != null :
		%ParticleModule.remove_particle(particle_scene)
	else :
		printerr("No particle scene!")

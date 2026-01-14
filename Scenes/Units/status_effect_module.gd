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

func apply_status_effect(status : StatusEffect) -> void:
	for effect in StatusEffects :
		if effect.Status_effect_name == status.Status_effect_name :
			var inst = status.duplicate(true)
			StatusEffects.append(inst)
			inst.on_apply(owner)
		else : 
			var index := StatusEffects.find(status)
			StatusEffects[index].add_stack(owner, status.stacks)

func remove_status_effect(status : StatusEffect) -> void:
	if StatusEffects.has(status) :
		StatusEffects.erase(status)

func cleanse_status_effects() -> void : 
	StatusEffects.clear()

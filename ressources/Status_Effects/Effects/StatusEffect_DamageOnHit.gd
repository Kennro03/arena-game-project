extends StatusEffect
class_name StatusEffect_DamageOnHit

signal emit_particle(particle_scene:PackedScene)

@export var damage : float = 2.0
@export var stack_loss_on_hit : int = 1
@export var particle_effect : PackedScene

var total_damage : float = 0.0
var _target_ref  # store reference for disconnect on expire

func on_apply(_target, _effect):
	super.on_apply(_target, _effect)
	_target_ref = _target
	if _target.has_signal("hit_received"):
		_target.hit_received.connect(_on_target_hit)

func on_expire(_target, _effect):
	if _target_ref and _target_ref.has_signal("hit_received"):
		if _target_ref.hit_received.is_connected(_on_target_hit):
			_target_ref.hit_received.disconnect(_on_target_hit)
	_target_ref = null

func _on_target_hit(_hit_data: HitData) -> void:
	if not is_instance_valid(_target_ref):
		return
	if _target_ref.has_method("take_damage"):
		var dmg := damage * stacks
		_target_ref.take_damage(dmg)
		total_damage += dmg
		if particle_effect:
			emit_particle.emit(particle_effect)
	if stack_loss_on_hit > 0:
		remove_stack(_target_ref, stack_loss_on_hit)

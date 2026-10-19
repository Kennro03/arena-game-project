extends StatusEffect
class_name StatusEffect_DamageOnHit

signal emit_particle(particle_scene:PackedScene)

@export var damage : float = 2.0
@export var stack_loss_on_hit : int = 1
@export var particle_effect : PackedScene

@export_group("Trigger Conditions")
@export var trigger_on_hit: bool = true
@export var trigger_on_block: bool = false
@export var trigger_on_parry: bool = false
# empty = trigger on any damage type.
@export var trigger_damage_types: Array[HitData.DamageType] = []

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

func _on_target_hit(hit_data: HitData) -> void:
	if not is_instance_valid(_target_ref):
		return
	if not _outcome_matches(hit_data.outcome):
		return
	if not trigger_damage_types.is_empty() and hit_data.damage_type not in trigger_damage_types:
		return

	if _target_ref.has_method("take_damage"):
		var dmg := damage * stacks
		_target_ref.take_damage(dmg)
		total_damage += dmg
		if particle_effect:
			emit_particle.emit(particle_effect)

	if stack_loss_on_hit > 0:
		remove_stack(_target_ref, stack_loss_on_hit)

func _outcome_matches(outcome: HitData.HitOutcome) -> bool:
	match outcome:
		HitData.HitOutcome.HIT:   return trigger_on_hit
		HitData.HitOutcome.BLOCK: return trigger_on_block
		HitData.HitOutcome.PARRY: return trigger_on_parry
		_:                        return false

func get_relevant_properties() -> Dictionary:
	var dict: Dictionary = super.get_relevant_properties()
	var type_str := "any" if trigger_damage_types.is_empty() else \
		", ".join(trigger_damage_types.map(func(t): return HitData.DamageType.find_key(t).capitalize()))
	dict.assign({
		"damage":       damage,
		"stack loss":   stack_loss_on_hit,
		"triggers on":  _build_outcome_string(),
		"damage types": type_str,
	})
	return dict

func _build_outcome_string() -> String:
	var parts: Array[String] = []
	if trigger_on_hit:   parts.append("hit")
	if trigger_on_block: parts.append("block")
	if trigger_on_parry: parts.append("parry")
	return ", ".join(parts) if not parts.is_empty() else "never"

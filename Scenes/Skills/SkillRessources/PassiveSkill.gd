extends Skill
class_name Passive_Skill

enum TriggerEvent {
	ON_HIT,
	ON_MULTITARGET_HIT,
	ON_PROJECTILE_HIT,
	ON_INFLICT_DAMAGE_TYPE,
	ON_HIT_RECEIVED,
	ON_RECEIVE_DAMAGE_TYPE,
	ON_APPLY_STATUS_EFFECT,
	ON_KILL,
	ON_LEVEL_UP,
	ON_HEALTH_BELOW_PERCENT,
	ON_SHIELD_DEPLETED,
	ON_CRIT,
	ON_DODGE,
	ON_PARRY,
	ON_BLOCK,
	ON_DEATH,
	ON_ROUND_START,
}

@export var trigger_event: TriggerEvent
@export_range(0.0, 1.0, 0.001) var trigger_chance: float = 1.0 
@export var cooldown: float = 0.0
#@export var conditions: Array[SkillCondition] = []
#@export var effects: Array[SkillEffect] = []

var _last_triggered: float = -INF
var _owner: BaseUnit

func activate(_caster: Node2D) -> void :
	if check_triggers() == true : 
		print("activated passive skill")
	pass

func check_triggers() -> bool :
	return true

func attach(unit: BaseUnit) -> void:
	_owner = unit
	_connect_trigger(unit)

func detach(unit: BaseUnit) -> void:
	_disconnect_trigger(unit)
	_owner = null

func _connect_trigger(unit: BaseUnit) -> void:
	match trigger_event:
		TriggerEvent.ON_HIT:
			unit.attack_performed.connect(_on_potential_trigger)
		TriggerEvent.ON_HIT_RECEIVED:
			unit.hit_received.connect(_on_potential_trigger)
		TriggerEvent.ON_KILL:
			unit.unit_died.connect(_on_kill_check)
		TriggerEvent.ON_LEVEL_UP:
			unit.stats.level_changed.connect(_on_potential_trigger.unbind(2))
		TriggerEvent.ON_SHIELD_DEPLETED:
			unit.stats.shield_depleted.connect(_on_potential_trigger)
		TriggerEvent.ON_HEALTH_BELOW_PERCENT:
			unit.stats.health_changed.connect(_on_health_changed)
		TriggerEvent.ON_DODGE:
			unit.hit_received.connect(_on_dodge_check)
		TriggerEvent.ON_PARRY:
			unit.hit_received.connect(_on_parry_check)
		TriggerEvent.ON_BLOCK:
			unit.hit_received.connect(_on_block_check)
		TriggerEvent.ON_CRIT:
			unit.hit_received.connect(_on_crit_check)

func _disconnect_trigger(_unit: BaseUnit) -> void:
	# mirror of _connect_trigger, disconnect each
	pass

func _on_potential_trigger(_arg = null) -> void:
	if randf() > trigger_chance:
		return
	if not _check_cooldown():
		return
	#if not conditions.all(func(c): return c.is_met(_owner, {})):
		#return
	_trigger()

func _on_kill_check(_dead_unit: BaseUnit, _killer: BaseUnit) -> void:
	if _killer == _owner:
		_on_potential_trigger()

func _on_dodge_check(hit: HitData) -> void:
	if hit.outcome == HitData.HitOutcome.DODGE:
		_on_potential_trigger(hit)

func _on_parry_check(hit: HitData) -> void:
	if hit.outcome == HitData.HitOutcome.PARRY:
		_on_potential_trigger(hit)

func _on_block_check(hit: HitData) -> void:
	if hit.outcome == HitData.HitOutcome.BLOCK:
		_on_potential_trigger(hit)

func _on_crit_check(hit: HitData) -> void:
	if hit.is_critical:
		_on_potential_trigger(hit)

func _on_health_changed(health: float, max_health: float) -> void:
	if health / max_health < 0.5:  # could make this a condition instead
		_on_potential_trigger()

func _check_cooldown() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_triggered < cooldown:
		return false
	return true

func _trigger() -> void:
	_last_triggered = Time.get_ticks_msec() / 1000.0
	#for effect in effects:
	#	effect.apply(_owner, {})

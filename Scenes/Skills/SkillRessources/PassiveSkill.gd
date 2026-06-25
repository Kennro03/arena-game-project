extends Skill
class_name Passive_Skill

@export var triggers: Array[SkillTrigger]
@export_range(0.0, 100.0, 0.1) var trigger_chance: float = 100.0 
@export var conditions: Array[SkillCondition] = []
@export var effects: Array[SkillEffect] = []

@export var cooldown: float = 0.0  # if cooldown = 0.0, passive doesn't recharge
@export var max_charges: int = 0  # if charges = 0, passive ignores charges and doesn't check for them
 
var _current_cooldown: float = 0.0
var _current_charges: int = 0
var _last_triggered: float = -INF
var _owner: BaseUnit

func attach(unit: BaseUnit) -> void:
	_owner = unit
	_current_charges = max_charges
	for trigger in triggers:
		trigger.connect_to_unit(unit, _on_triggered)

func detach(unit: BaseUnit) -> void:
	for trigger in triggers:
		trigger.disconnect_from_unit(unit, _on_triggered)
	_owner = null

func _on_triggered(context: Dictionary = {}) -> void:
	if randf_range(0.0,100.0) > trigger_chance :
		return
	if _current_cooldown > 0.0:
		return
	if max_charges > 0 and _current_charges <= 0:
		return
	if not conditions.all(func(c): return c.is_met(_owner, context)):
		return
	
	for effect in effects:
		effect.apply(_owner, context)
	
	if max_charges > 0 :
		_current_charges -= 1
		if _current_charges <= 0 and cooldown > 0.0:
			_current_cooldown = cooldown

func tick(delta: float) -> void:
	if _current_cooldown > 0.0:
		_current_cooldown -= delta
		if _current_cooldown <= 0.0:
			_current_cooldown = 0.0
			_current_charges = max_charges
	
	for trigger in triggers:
		trigger.tick(delta)  

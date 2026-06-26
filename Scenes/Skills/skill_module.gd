extends Node
class_name SkillModule

@export var skill_check_delay : float = 0.5 #delay between checking for available skills 
@export var general_cooldown_after_cast: float = 1.0
  
var skill_list: Array[Skill] = []
var _active_skills: Array[ActiveSkill] = []
var _passive_skills: Array[Passive_Skill] = []

var _general_cooldown: float = 0.0
var _is_casting: bool = false
var _check_timer: float = 0.0

func _ready() -> void:
	await owner.ready
	var unit := owner as BaseUnit
	
	print("SkillModule ready for %s, unit_data skills: %s" % [
		unit.display_name, 
		unit.unit_data.skill_list.map(func(s): return s.name) if unit.unit_data else []
	])
	
	#if unit and unit.unit_data:
	#	for skill in unit.unit_data.skill_list:
	#		_register_skill(skill)
	#for skill in skill_list:
	#	_register_skill(skill)

func _tick(delta: float) -> void:
	# tick cooldowns
	if _general_cooldown > 0.0:
		_general_cooldown -= delta
	
	for skill in _active_skills:
		#print("Ticking skill %s cooldown: %s" % [skill.name, skill._current_cooldown])
		skill.tick(delta)
	for skill in _passive_skills:
		#print("Ticking skill %s cooldown: %s" % [skill.name, skill._current_cooldown])
		skill.tick(delta)
	
	# periodic skill check
	_check_timer += delta
	if _check_timer >= skill_check_delay:
		_check_timer = 0.0
		_try_use_skill()

func add_skill(skill: Skill) -> void:
	if _has_skill(skill):
		push_warning("Skill %s already registered" % skill.skill_name)
		return
	skill_list.append(skill)
	_register_skill(skill)

func remove_skill(skill: Skill) -> void:
	skill_list.erase(skill)
	if skill is ActiveSkill:
		var active := skill as ActiveSkill
		active.detach(owner)
		_active_skills.erase(active)
	elif skill is Passive_Skill:
		var passive := skill as Passive_Skill
		passive.detach(owner as BaseUnit)
		_passive_skills.erase(passive)

func _register_skill(skill: Skill) -> void:
	print("Registering: %s, total active after: %d" % [skill.name, _active_skills.size() + 1])
	# duplicate so runtime state is unique per unit
	if skill is ActiveSkill:
		var active := skill.duplicate(true) as ActiveSkill
		active.attach(owner as BaseUnit)
		active.cast_started.connect(_on_cast_started)
		active.cast_completed.connect(_on_cast_completed)
		active.cast_interrupted.connect(_on_cast_interrupted)
		_active_skills.append(active)
	elif skill is Passive_Skill:
		var passive := skill.duplicate(true) as Passive_Skill
		passive.attach(owner as BaseUnit)
		_passive_skills.append(passive)

func _has_skill(skill: Skill) -> bool:
	return skill_list.any(func(s): return s.skill_name == skill.skill_name)

func _try_use_skill() -> void:
	if _is_casting or _general_cooldown > 0.0:
		return
	var unit := owner as BaseUnit
	if unit.is_stunned or unit.is_silenced:
		return
	var skill := _get_best_usable_skill()
	if skill:
		use_skill(skill)

func use_skill(skill: ActiveSkill) -> void:
	if not skill.can_use() or _is_casting:
		return
	var target: BaseUnit = null
	if skill.targeting:
		target = skill.targeting.get_target(owner as BaseUnit)
		print("Targeting result: ", target)
	else:
		print("No targeting set on skill: ", skill.skill_name)
	skill.use(target)

func use_skill_by_index(index: int) -> void:
	if index < 0 or index >= _active_skills.size():
		return
	use_skill(_active_skills[index])

func use_skill_by_name(skill_name: String) -> void:
	for skill in _active_skills:
		if skill.skill_name == skill_name:
			use_skill(skill)
			return

func _get_best_usable_skill() -> ActiveSkill:
	var usable := get_usable_skills()
	if usable.is_empty():
		return null
	## for now, use first usable skill wins, later add priority field to ActiveSkill and sort by it
	return usable[0]

func get_usable_skills() -> Array[ActiveSkill]:
	var result: Array[ActiveSkill] = []
	for skill in _active_skills:
		if skill.can_use():
			result.append(skill)
	return result

func is_casting() -> bool:
	return _is_casting

func interrupt_active_skills(cause: String = "hit") -> void:
	for skill in _active_skills:
		skill.try_interrupt(cause)

func _on_cast_started(_skill: ActiveSkill) -> void:
	_is_casting = true

func _on_cast_completed(_skill: ActiveSkill) -> void:
	_is_casting = false
	_general_cooldown = general_cooldown_after_cast

func _on_cast_interrupted(_skill: ActiveSkill) -> void:
	_is_casting = false
	_general_cooldown = 0.0  # no penalty for interrupted cast

func has_passive_with_tag(tag: String) -> bool:
	return _passive_skills.any(func(p): return tag in p.tags)

func has_skill_with_name(skill_name: String) -> bool:
	return skill_list.any(func(s): return s.skill_name == skill_name)

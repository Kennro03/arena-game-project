extends RefCounted
class_name SkillRuntime

var skill_module: SkillModule
var skill_data: ActiveSkill
var caster: Node2D
var is_on_cooldown:= false 

var targets: Array[Node2D] 
var hit_targets: Array[Node2D] 
var target_point: Vector2

var cooldown_time_passed: float = 0.0
var casting_time_passed: float = 0.0
var context: Dictionary = {}
 
func _init(skill: ActiveSkill, owner: Node2D):
	skill_data = skill
	caster = owner

func _process(delta) -> void:
	print(str(cooldown_time_passed))
	if caster.is_casting == true :
		casting_time_passed += delta
		if casting_time_passed >= skill_data.activation_time:
			casting_time_passed -= skill_data.activation_time
			caster.is_casting = false
			print(skill_data.skill_name + " cast ended.")
	if is_on_cooldown == true :
		cooldown_time_passed += delta
		if cooldown_time_passed >= skill_data.cooldown:
			cooldown_time_passed -= skill_data.cooldown
			is_on_cooldown = false
			print(caster.name + " skill : " + skill_data.skill_name + " cooldown ended.")
	
	if skill_data.spawn_effects :
		targets = get_hitboxes_targets()
	do_apply_effects(caster, context)

func _activate(_context: Dictionary = {}) -> void :
	_context.set("target_point",target_point)
	if _check_cast_conditions(_context):
		print("Conditions met for " + skill_data.skill_name)
		_start_cast(_context)

func _start_cast(_context: Dictionary) -> void:
	if skill_data.activation_time > 0.0 and !caster.is_casting:
		print("Casting " + skill_data.skill_name + " (" + str(skill_data.activation_time) + "s)")
		caster.is_casting = true
		_start_cooldown()
		do_targeting_effects(caster, _context)
		do_spawn_effects(caster, _context)

func _start_cooldown() -> void:
	print("Started cooldown")
	if skill_data.cooldown <= 0:
		return
	else : 
		is_on_cooldown = true

func _check_targets_distance(_range: float , _context: Dictionary = {}) -> bool:
	if _range > 0.0 :
		if caster.get_closest_unit() : 
			if caster.get_closest_unit().position.distance_to(caster.position) < skill_data.activation_range :
				print(str(caster.get_closest_unit().position.distance_to(caster.position)))
				return true
		return false
	else : 
		return true

func do_targeting_effects(skill_caster, _context):
	for eff in skill_data.targeting_effects:
		eff.apply(skill_caster, _context)

func do_spawn_effects(skill_caster, _context):
	for eff in skill_data.spawn_effects:
		eff.apply(skill_caster, _context)

func get_hitboxes_targets():
	var targets_inside_hitboxes : Array[Node2D] = []
	for eff in skill_data.spawn_effects:
		if eff.has_method("get_targets") :
			for t in eff.get_targets():
				if is_instance_valid(t) and not targets_inside_hitboxes.has(t):
					targets_inside_hitboxes.append(t)
	return targets_inside_hitboxes

func do_apply_effects(skill_caster, _context):
	for eff in skill_data.apply_effects:
		context.set("targets",targets.filter(func(t): return not hit_targets.has(t))) #affect only targets that haven't been affected yet
		eff.apply(skill_caster, _context)
		for target in targets : 
			if !hit_targets.has(target) :
				hit_targets.append(target)
	

func do_end_effects(skill_caster, _context):
	for eff in skill_data.end_effects:
		eff.apply(skill_caster, _context)

func get_targets_from_hitboxes():
	for hitbox in skill_data.HitboxEffect.hitbox_scene :
		pass

func check_usable(_context: Dictionary = {}) -> bool :
	if is_on_cooldown == true : 
		printerr("Skill is on cooldown !")
		return false
	elif !skill_data : 
		printerr("Skill has no skill_data !")
		return false
	elif !caster : 
		printerr("Skill has no caster !")
		return false
	else : 
		return  true

func _check_cast_conditions(_context: Dictionary = {}) -> bool:
	if caster.is_casting :
		printerr("caster already casting !")
		return false
	elif caster.is_stunned :
		printerr("caster is stunned !")
		return false
	elif !_check_targets_distance(skill_data.activation_range) :
		printerr("target too far away !")
		return false
	else :
		return true

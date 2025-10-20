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
var duration_time_passed: float = 0.0
var context: Dictionary = {}
var skill_activated: bool = false
 
func _init(skill: ActiveSkill, owner: Node2D):
	skill_data = skill
	caster = owner
	
	skill_data = skill.duplicate(true)

func _process(delta) -> void:
	if caster.is_casting == true :
		casting_time_passed += delta
		if casting_time_passed >= skill_data.activation_time:
			casting_time_passed -= skill_data.activation_time
			caster.is_casting = false
			#print(skill_data.skill_name + " cast ended.")
	if is_on_cooldown == true :
		cooldown_time_passed += delta
		if cooldown_time_passed >= skill_data.cooldown:
			cooldown_time_passed -= skill_data.cooldown
			is_on_cooldown = false
			#print(caster.name + " skill : " + skill_data.skill_name + " cooldown ended.")
	
	if skill_activated : 
		targets = get_hitboxes_targets()
		do_apply_effects(caster, context)
		duration_time_passed += delta
		
		if duration_time_passed >= skill_data.duration:
			duration_time_passed -= skill_data.duration
			do_end_effects(caster,context)
			#print(skill_data.skill_name + " ended.")

func _activate(_context: Dictionary = {}) -> void :
	_context.set("target_point",target_point)
	#print("Activating skill : " + skill_data.skill_name)
	_start_cast(_context)

func _start_cast(_context: Dictionary) -> void:
	if skill_data.activation_time > 0.0 :
		#print("Casting " + skill_data.skill_name + " (" + str(skill_data.activation_time) + "s)")
		caster.is_casting = true
		hit_targets = []
		_start_cooldown()
		do_targeting_effects(caster, _context)
		do_spawn_effects(caster, _context)
		skill_activated = true
	else : 
		#print("Instant cast " + skill_data.skill_name + " (" + str(skill_data.activation_time) + "s)")
		_start_cooldown()
		do_targeting_effects(caster, _context)
		do_spawn_effects(caster, _context)
		skill_activated = true

func _start_cooldown() -> void:
	#print("Started cooldown")
	if skill_data.cooldown <= 0:
		return
	else : 
		is_on_cooldown = true

func _check_targets_distance(_range: float , _context: Dictionary = {}) -> bool:
	if _range > 0.0 :
		if caster.get_closest_unit() : 
			if caster.get_closest_unit().position.distance_to(caster.position) < skill_data.activation_range :
				#print(str(caster.get_closest_unit().position.distance_to(caster.position)))
				return true
		return false
	else : 
		return true

func do_targeting_effects(skill_caster, _context):
	for eff in skill_data.targeting_effects:
		eff.apply(skill_caster, _context)

func do_spawn_effects(skill_caster, _context):
	_context.set("target_point",caster.get_closest_unit())
	for eff in skill_data.spawn_effects:
		eff.apply(skill_caster, _context)

func get_hitboxes_targets() -> Array[Node2D]:
	var targets_inside_hitboxes : Array[Node2D] = []
	for eff in skill_data.spawn_effects:
		if eff.has_method("get_targets") and eff.hitbox :
			for t in eff.get_targets():
				if is_instance_valid(t) and not targets_inside_hitboxes.has(t):
					targets_inside_hitboxes.append(t)
	return targets_inside_hitboxes

func do_apply_effects(skill_caster, _context):
	#print("Targets in context : " + str(context.get("targets")) + " --- and in list : " + str(get_hitboxes_targets()))
	targets = get_hitboxes_targets() #get targets inside hitbox
	context.set("targets",targets.filter(func(t): return not hit_targets.has(t))) #affect only targets that haven't been affected yet
	var hit : HitData = HitData.new()
	var hit_result
	for eff in skill_data.apply_effects:
		hit_result = eff.modify_hit(skill_caster,hit, _context)
	for target in targets : 
		if !hit_targets.has(target) and target!=skill_caster :
			print("Hit damage="+str(hit_result.damage) +" knockback-strength="+str(hit_result.knockback_force) +" knockback-direction="+str(hit_result.knockback_direction))
			if target.has_method("resolve_hit") :
				target.resolve_hit(hit_result)
			hit_targets.append(target)

func do_end_effects(skill_caster, _context):
	for eff in skill_data.end_effects:
		eff.apply(skill_caster, _context)
	skill_activated = false

func get_targets_from_hitboxes():
	for hitbox in skill_data.HitboxEffect.hitbox_scene :
		pass

func check_usable(_context: Dictionary = {}) -> bool :
	if !skill_data : 
		printerr("Skill has no skill_data !")
		return false
	elif !caster : 
		printerr("Skill has no caster !")
		return false
	elif is_on_cooldown == true : 
		#print("Skill is on cooldown !")
		return false
	else : 
		return  true

func _check_cast_conditions(_context: Dictionary = {}) -> bool:
	if caster.is_casting :
		print("caster already casting !")
		return false
	elif caster.is_stunned :
		print("caster is stunned !")
		return false
	elif !_check_targets_distance(skill_data.activation_range) :
		#print("no valid target !")
		return false
	else :
		return true

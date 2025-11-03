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

var active_spawn_effects: Array[SpawnEffect] = []
 
func _init(skill: ActiveSkill, owner: Node2D):
	skill_data = skill
	caster = owner
	skill_data = skill.duplicate(true)

func _process(delta) -> void:
	active_spawn_effects = sanitize_spawn_effects(active_spawn_effects)
	
	if caster.is_casting == true :
		casting_time_passed += delta
		if casting_time_passed >= skill_data.cast_time:
			casting_time_passed -= skill_data.cast_time
			caster.is_casting = false
			print(skill_data.skill_name + " cast ended.")
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

func activate(_context: Dictionary = {}) -> void:
	_context.set("target_point",target_point)
	hit_targets = []
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

func do_targeting_effects(_skill_caster, _context):
	_context.set("activation_range",skill_data.activation_range)
	#for eff in skill_data.targeting_effects:
	#	eff.apply(skill_caster, _context)

func do_spawn_effects(_skill_caster, _context):
	_context.set("target_point",_skill_caster.get_closest_unit())
	for eff in skill_data.spawn_effects:
		var eff_instance = eff.duplicate(true) 
		eff_instance.spawn(_skill_caster, _context)
		eff_instance.connect("hitboxeffect_finished",Callable(self, "_on_hitboxeffect_expired"))
		active_spawn_effects.append(eff_instance)

func get_hitboxes_targets() -> Array[Node2D]:
	var all_targets: Array[Node2D] = []
	for eff in active_spawn_effects:
		if eff!= null and eff.has_method("get_targets"):
			all_targets += eff.get_targets(caster)
	return all_targets

func do_apply_effects(skill_caster, _context):
	#print("Targets in context : " + str(context.get("targets")) + " --- and in list : " + str(get_hitboxes_targets()))
	if skill_data.apply_effects : 
		targets = get_hitboxes_targets() #get targets inside hitbox
		targets = targets.filter(func(t): return is_instance_valid(t))
		hit_targets = hit_targets.filter(func(h): return is_instance_valid(h))
		context.set("targets",targets.filter(func(t): return is_instance_valid(t) and not hit_targets.has(t))) #affect only targets that haven't been affected yet
		var hit : HitData = HitData.new()
		var hit_result : HitData
		for eff in skill_data.apply_effects:
			hit_result = eff.modify_hit(skill_caster,hit, _context)
		for target in targets : 
			if target and !hit_targets.has(target) and target!=skill_caster :
				#print("Hit damage="+str(hit_result.damage) +" knockback-strength="+str(hit_result.knockback_force) +" knockback-direction="+str(hit_result.knockback_direction))
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

func sanitize_spawn_effects(array : Array[SpawnEffect]) -> Array[SpawnEffect] :
	var sanitized_array : Array[SpawnEffect]
	for i in array :
		if is_instance_valid(i) :
			sanitized_array.append(i)
		else : 
			printerr("Hitbox " + str(i) + " broken or missing, removing from skill references")
	return sanitized_array

func _on_hitboxeffect_expired(hitboxeffect : SpawnEffect) :
	#printerr(str(hitboxeffect) + " has expired, removing from active spawn effects")
	active_spawn_effects.erase(hitboxeffect)
	pass

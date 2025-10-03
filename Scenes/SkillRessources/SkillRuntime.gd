extends RefCounted
class_name SkillRuntime

var skill_data: ActiveSkill
var caster: Node2D
var is_on_cooldown: bool = false

var targets: Array[Node2D] 
var target_points: Array[Vector2]

var cooldown_time_passed: float = 0.0
var casting_time_passed: float = 0.0
 
func _init(skill_data: ActiveSkill, caster: Node2D):
	self.skill_data = skill_data
	self.caster = caster

func _process(delta) -> void:
	if caster.is_casting :
		casting_time_passed += delta
		if casting_time_passed >= skill_data.activation_time:
			casting_time_passed -= skill_data.activation_time
			caster.is_casting = false
			print(skill_data.skill_name + " cast ended.")
	if is_on_cooldown :
		cooldown_time_passed += delta
		if cooldown_time_passed >= skill_data.cooldown:
			cooldown_time_passed -= skill_data.cooldown
			is_on_cooldown = false
			print(skill_data.skill_name + " cooldown ended.")


func activate(_caster: Node2D, _context: Dictionary = {}) -> void :
	# Default behavior — can be overridden
	if not _check_conditions(_context):
		print("Conditions not met for " + skill_data.skill_name)
		return
	else :
		_start_cast(_caster, _context)

func _start_cast(_caster: Node2D, _context: Dictionary) -> void:
	if skill_data.activation_time > 0.0 and !caster.is_casting:
		print("Casting " + skill_data.skill_name + " (" + str(skill_data.activation_time) + "s)")
		caster.is_casting = true
	#FINISH THIS WHOLE FUNCTION
	_start_cooldown()

func check_range(caster: Node2D) -> bool :
	var closest_target : Node2D 
	for target in targets : 
		if (caster.position.distance_to(target.position) < skill_data.skill_range) :
			pass 
			#FINISH THIS WHOLE FUNCTION
	return false

# Cooldown management
func _start_cooldown() -> void:
	if skill_data.cooldown <= 0:
		return
	else : 
		is_on_cooldown = true

func _check_conditions(_context: Dictionary = {}) -> bool:
	# Optional condition override 
	return true

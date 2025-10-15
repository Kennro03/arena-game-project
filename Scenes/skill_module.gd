extends Node
class_name SkillModule

@export var skill_check_delay : float = 0.25
var time_passed : float
var skill_list: Array[Skill] = []
var skill_runtimes: Dictionary = {}
var context : Dictionary = {}

func add_skill(skill: Skill, slot: int = -1):
	print("Adding skill " + str(skill) + " to " + str(Stickman))
	if skill_runtimes.has(skill.skill_name):
		push_warning("Skill " + skill.skill_name + " already added." )
		return
	
	if slot == -1 or slot >= skill_list.size():
		print("Added skill " + skill.skill_name)
		skill_list.append(skill)
	else:
		print("Inserted skill " + skill.skill_name + " in slot " +str(slot))
		skill_list.insert(slot, skill)
	
	#skill_list.append(skill)
	create_skill_runtime(skill)

func remove_skill(skill: Skill, _slot: int = -1):
	if skill_runtimes.has(skill.skill_name):
		skill_runtimes.erase(skill.skill_name)
	
	# Also remove from array
	for i in range(skill_list.size()):
		if skill_list[i].skill_name == skill.skill_name:
			skill_list.remove_at(i)
			break

func use_skill_by_name(skill_name: String, context: Dictionary = {}):
	if skill_name in skill_runtimes:
		skill_runtimes[skill_name].activate(context)

func use_skill_by_slot(slot: int, context: Dictionary = {}):
	if slot >= 0 and slot < skill_list.size():
		var skill = skill_list[slot]
		use_skill_by_name(skill.skill_name, context)

func create_skill_runtime(skill_to_add: Skill) -> void : 
	if skill_runtimes.has(skill_to_add.skill_name):
		push_warning("Skill " + skill_to_add.skill_name + " already added." )
		return
	else : 
		skill_runtimes[skill_to_add.skill_name] = SkillRuntime.new(skill_to_add, owner)

func actualize_context() -> void : 
	context.set("caster",owner)
	context.set("skill_target",owner.get_closest_unit())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	for skill in skill_list : 
		create_skill_runtime(skill)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var using_skill := false
	for i in skill_runtimes :
		skill_runtimes[i]._process(_delta)
	
	time_passed += _delta
	if time_passed >= skill_check_delay : 
		time_passed -= skill_check_delay
		
		for skill_key in skill_runtimes :
			#print("checking conditions for " + str(skill_runtimes[skill_key].skill_data.skill_name) + " : usable=" + str(skill_runtimes[skill_key].check_usable()) + " cast_conditions=" + str(skill_runtimes[skill_key]._check_cast_conditions()))
			if not using_skill and skill_runtimes[skill_key].check_usable() and skill_runtimes[skill_key]._check_cast_conditions() :
				#print("Skill module using : "+ skill_runtimes[skill_key].skill_data.skill_name)
				skill_runtimes[skill_key]._activate()
				using_skill = true
		pass
	
	
	
	
	pass

extends Node
class_name SkillModule

var skill_list: Array[Skill] = []
var skill_runtimes: Dictionary = {}

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

func create_skill_runtime(skill: Skill) -> void : 
	skill_runtimes[skill.skill_name] = SkillRuntime.new(skill, get_parent())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for skill in skill_list : 
		pass
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for skill in skill_runtimes :
		if skill.check_usable() :
			skill.activate()
		pass
	
	pass

extends Resource
class_name Skill

# normal skills appear during selection, 
#rare skills are more rare and limited to a certain number per selection/every x selection or just rarer
#exclusive skills can't be obtained, things like given skills to some enemy, some skills given to gear, etc
enum SkillCategory { NORMAL, RARE,  EXCLUSIVE} 

@export var category: SkillCategory = SkillCategory.NORMAL
@export var name: String = "Unnamed Skill"
@export var description: String = "No desc"
@export var icon: Texture2D 
@export var tags: Array[String] = []  # for filtering in draw selection: ["offensive", "mobility", etc.]
@export var prerequisites: Array[SkillPrerequisite] = []
@export var ticks_when_alive: bool = true
@export var usable_when_alive: bool = true
@export var ticks_when_downed: bool = false
@export var usable_when_downed: bool = false

func are_prerequisites_met(unit: BaseUnit) -> bool:
	return prerequisites.all(func(p): return p.is_met(unit))

func get_prerequisites_description() -> String:
	if prerequisites.is_empty():
		return ""
	return "\n".join(prerequisites.map(func(p): return p.get_description()))

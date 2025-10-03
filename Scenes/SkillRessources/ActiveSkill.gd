extends Skill
class_name ActiveSkill

@export var skill_range: float = 100.0
@export var cooldown: float = 10.0
@export var activation_time: float = 0.0
@export var placement_component: Array[SkillEffect]
@export var components : Array[SkillEffect]

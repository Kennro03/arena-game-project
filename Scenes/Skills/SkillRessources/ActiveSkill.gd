extends Skill
class_name ActiveSkill

@export var cooldown: float = 5.0
@export var duration: float = 1.0
@export var activation_time: float = 0.5
@export var activation_range: float = 0.0

@export var targeting_effects: Array[TargetingEffect] = []   # where or who to affect, such as closest enemy/ally
@export var spawn_effects: Array[SpawnEffect] = []       # hitboxes and/or projectiles
@export var apply_effects: Array[ApplyEffect] = []       # damage, knockback, buffs, and all other effects to apply to targets
@export var end_effects: Array[EndEffect] = []         # cleanup, delayed triggers

extends StatusEffect
class_name StatusEffect_Stat_Buff

signal emit_particle(particle_scene:PackedScene)
signal stop_particle(particle_scene:PackedScene)

@export var stat_buff : StatBuff
@export var particle_effect : PackedScene

var default_buff_particle_scene : PackedScene = preload("uid://bp8e0bj146pk6")
var default_debuff_particle_scene : PackedScene = preload("uid://njey8a1fxu3e")

func on_apply(_target, _effect):
	#print("Applying " + str(Status_effect_name))
	stacks += max(0, _effect.stacks_affliction)
	if stat_buff :
		#print("Applying " + str(Status_effect_name) + " debuff = " + str(debuff))
		_target.stats.add_buff(stat_buff)
	if particle_effect :
		#print("Emitting particle effect slow ")
		emit_particle.emit(particle_effect)

func on_expire(_target, _effect):
	#print("Target stat buffs list = " + str(_target.stats.stat_buffs))
	if _target.stats.stat_buffs.has(stat_buff) :
		_target.stats.remove_buff(stat_buff)
	if particle_effect :
		stop_particle.emit(particle_effect)

func setup(_stat_buff : StatBuff, _name : String = "", _id : String = "", _description : String = "") -> StatusEffect_Stat_Buff:
	# random buff generation : 
	#var buff : StatBuff = StatBuff.new(Stats.Attributes.values().pick_random(), randi() % 10 + 11, StatBuff.BuffType.ADD)
	stat_buff = _stat_buff
	Status_effect_name = _name
	status_ID = _id
	Status_effect_description = _description
	_generate_metadata()
	return self

func _generate_metadata():
	var ext : String
	if (stat_buff.buff_type == StatBuff.BuffType.ADD and stat_buff.buff_amount > 0) or (stat_buff.buff_type == StatBuff.BuffType.MULTIPLY and stat_buff.buff_amount >= 1) :
		ext = "Buff"
		if !particle_effect :
			particle_effect = default_buff_particle_scene
	else : 
		ext = "Debuff"
		if !particle_effect :
			particle_effect = default_debuff_particle_scene
	
	var stat_name : String = Stats.BuffableStats.keys()[stat_buff.stat]
	if Status_effect_name == "":
		Status_effect_name = stat_name + " " + ext
	if status_ID == "":
		status_ID = stat_name.to_lower() + "_" + ext
	if Status_effect_description == "":
		Status_effect_description = "An " + stat_name + " " + ext + " that affects stats temporarily."

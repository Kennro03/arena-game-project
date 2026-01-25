extends StatusEffect
class_name StatusEffect_Stat_Buff

signal emit_particle(particle_scene:PackedScene)
signal stop_particle(particle_scene:PackedScene)

@export var stat_buff : StatBuff
@export var particle_effect : PackedScene

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

func get_random_attribute_stat_buff(_value : int = 0, _buff_type : StatBuff.BuffType = StatBuff.BuffType.ADD) -> StatBuff :
	if _value == 0 and _buff_type == StatBuff.BuffType.ADD :
		_value = randi() % 10 + 11
		print("Using random value, turning 0 to " + str(_value))
	var buff : StatBuff = StatBuff.new(Stats.Attributes.values().pick_random(), _value, _buff_type)
	return buff 

func _init(_stat_buff : StatBuff = null) -> void:
	if _stat_buff == null :
		_stat_buff = get_random_attribute_stat_buff()
		print("Getting random Attribute stat buff : " + str(_stat_buff))
	
	var ext : String
	if (_stat_buff.buff_type == StatBuff.BuffType.ADD and _stat_buff.buff_amount > 0) or (_stat_buff.buff_type == StatBuff.BuffType.MULTIPLY and _stat_buff.buff_amount >= 1) :
		ext = "Buff"
	else : 
		ext = "Debuff"
	Status_effect_name = Stats.BuffableStats.values()[_stat_buff.stat].to_upper() + " " + 
	status_ID = Stats.BuffableStats.values()[_stat_buff.stat].to_lower() + "_Buff"
	Status_effect_description = "An " + Stats.BuffableStats.values()[_stat_buff.stat] + " Buff"
	pass

extends Resource
class_name StatusEffect

@export var Status_effect_name : String
@export var status_ID : String
@export var Status_effect_description : String
@export var status_icon : Texture2D

@export var stacks_affliction : int = 1
@export var max_stacks : int = 1
@export var duration : float = 5.0
@export var tick_interval : float = 1.0
@export var refresh_on_application : bool = false

var stacks : int = 0
var elapsed : float = 0.0
var tick_timer := 0.0

func update(target, delta) -> bool:
	if tick_interval >= 0.0 :
		tick_timer += delta
		
		if tick_timer >= tick_interval:
			#print(str(Status_effect_name) + " ticked")
			tick_timer -= tick_interval
			on_tick(target, self)
	
	if duration >= 0.0 :
		elapsed += delta
		#print(self, " elapsed=", elapsed)
		
		if elapsed >= duration:
			on_expire(target, self)
			return true # finished
	
	if stacks <= 0 :
		print(str(Status_effect_name) + " stacks reached 0")
		on_expire(target, self)
		return true # finished
	
	return false

func on_apply(_target, _effect): 
	#print("Applying " + str(Status_effect_name))
	stacks += max(0, _effect.stacks_affliction)

func on_tick(_target, _effect): pass

func on_expire(_target, _effect): pass

func add_stack(target, amount :int= 1):
	if stacks != max_stacks :
		#print(str(Status_effect_name) + " Adding stack " + str(amount) + " to current (" + str(stacks) + ")")
		stacks = min(stacks + amount, max_stacks)
		on_stack_changed(target, self)

func remove_stack(target, amount :int= 1):
	stacks = min(stacks - amount, 0)
	on_stack_changed(target, self)

func on_stack_changed(_target, _effect): 
	#print(str(Status_effect_name) + " changed stacks to " + str(stacks))
	if stacks <= 0 :
		elapsed = duration

func refresh_duration()->void :
	self.elapsed = 0.0
	

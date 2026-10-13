extends AnimatedSprite2D
class_name HitEffect

func _ready() -> void:
	pass

func play_for_damage_type(type: HitData.DamageType) -> void:
	match type:
		HitData.DamageType.SLASH:  
			play(&"slash")
		HitData.DamageType.BLUNT:  
			play(&"blunt")
		HitData.DamageType.PIERCE: 
			play(&"pierce")
		_:                         
			play(&"default")

func setup(hit_data: HitData) -> void:
	print("Damage type = " + str(hit_data.damage_type))
	play_for_damage_type(hit_data.damage_type)
	
	var dir := hit_data.knockback_direction
	if dir == Vector2.ZERO and is_instance_valid(hit_data.hit_owner):
		dir = (global_position - hit_data.hit_owner.global_position).normalized()
	if dir != Vector2.ZERO:
		rotation = dir.angle()

func _on_animation_finished() -> void:
	queue_free()

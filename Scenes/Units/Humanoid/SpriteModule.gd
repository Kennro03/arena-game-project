extends Node2D
class_name SpriteModule

@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Signals from BaseUnit get forwarded here
func update_sprites() -> void: pass  # called when sprites/armor/weapon change
func play_idle() -> void: pass
func play_move(_direction: Vector2) -> void: pass
func play_attack(_attack_type: Weapon.AttackTypeEnum, _weapon: Weapon) -> void: pass
func play_hurt() -> void: pass
func play_death() -> void: pass
func play_block() -> void: pass
func play_parry() -> void: pass
func play_dodge() -> void: pass
func play_instant_cast() -> void: pass 
func play_channel_cast() -> void: pass 

extends CanvasGroup
class_name SpriteModule

var flip : bool = false

@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Signals from BaseUnit get forwarded here
func update_sprites() -> void: pass  # called when sprites/armor/weapon change
func play_idle() -> void: pass
func play_move() -> void: pass
func play_attack() -> void: pass
func play_hurt() -> void: pass
func play_death() -> void: pass
func play_block() -> void: pass
func play_parry() -> void: pass
func play_dodge() -> void: pass
func play_instant_cast() -> void: pass 
func play_channel_cast() -> void: pass 

func flipSprite(flipped: bool) -> void:
	if flip == flipped:
		return
	self.scale.x = -1
	flip = flipped

func get_random_animation(prefix: String) -> String:
	var matches : Array[String] = []
	for anim in animation_player.get_animation_list():
		if anim.begins_with(prefix):
			matches.append(anim)
	print("animation matches found : " + str(matches))
	return matches.pick_random() if not matches.is_empty() else ""

func play_candidates(candidates:Array[String] = [], playspeed : float = 1.0) -> void :   
	# try most specific first: category_style_type
	# then fall back through progressively more generic
	for anim in candidates:
		if animation_player.has_animation(anim):
			var selected_animation := get_random_animation(anim)
			animation_player.play(selected_animation,-1,playspeed)
			await animation_player.animation_finished
			return

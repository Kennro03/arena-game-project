extends BaseUnitState
class_name BaseUnitCyclingAnims

var _is_cycling: bool = false

func enter(_previous_state_path: String, _data := {}) -> void:
	print("Now cycling between available animations.")
	_start_cycling()

func _start_cycling() -> void:
	if _is_cycling:
		return
	_is_cycling = true
	_cycle.call_deferred()

func _cycle() -> void:
	var animations := unit.spriteModule.animation_player.get_animation_list()
	for anim in animations:
		if anim.contains("RESET") or anim.contains("go_down"):
			continue
		print("Now playing: %s" % anim)
		unit.spriteModule.animation_player.play(anim)
		await get_tree().create_timer(2.0).timeout
		
		# wait for RESET to fully complete before next animation
		unit.spriteModule.animation_player.play("RESET")
		await unit.spriteModule.animation_player.animation_finished
	
	_is_cycling = false
	_cycle.call_deferred()

func exit() -> void:
	_is_cycling = false

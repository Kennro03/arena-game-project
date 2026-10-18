extends Node2D
class_name ParticleModule

@export var hit_effect_scene: PackedScene  

var DamagePopupNode : PackedScene = preload("res://Scenes/UI/floating_number.tscn")
var block_particle : PackedScene = preload("res://Scenes/VFX/block_particles_2d.tscn")
var parry_particle : PackedScene = preload("res://Scenes/VFX/parry_particles_2d.tscn")
var hit_particle : PackedScene = preload("res://Scenes/VFX/hit_particles_2d.tscn")
var level_up_particle : PackedScene = preload("res://Scenes/VFX/level_up_particles_2d.tscn")

var _active_particles := {}

const DMG_POPUP_OFFSET : Vector2 = Vector2(0.0,6.0)
const DAMAGE_TYPE_ICONS = preload("uid://cg8gvwwsfrqmp")

# ── Public API ────────────────────────────────────────────────────────────
func text_popup(
	text: String,
	text_scale: float = 1.0,
	text_color: Color = Color.WHITE,
	movement_multiplier: float = 1.0,
	icon_index: int = -1
) -> void:
	_spawn_popup(text, text_scale, text_color, movement_multiplier, icon_index)

func damage_popup(hit_data: HitData, damage_override: float = -1.0) -> void:
	var damage : float = damage_override if damage_override >= 0.0 else hit_data.base_damage
	var text  : String = str(roundi(damage))
	var scale : float = _damage_to_scale(damage)
	var color : Color = Color.WHITE
	var icon_idx: int = HitData.DAMAGE_TYPE_SPRITE_INDEX.get(hit_data.damage_type, -1)
	
	if hit_data.is_critical:
		scale = minf(scale * 1.4, 2.0)
		color = Color("FFD700")
	
	_spawn_popup(text, scale, color, 1.0, icon_idx)

# ── Internals ─────────────────────────────────────────────────────────────
func _spawn_popup(
	text: String,
	text_scale: float,
	text_color: Color,
	movement_multiplier: float,
	icon_index: int
) -> void:
	if DamagePopupNode == null:
		printerr("Damage Popup Scene not assigned!")
		return

	var popup := DamagePopupNode.instantiate()
	popup.position = global_position + DMG_POPUP_OFFSET
	popup.scale    = Vector2(text_scale, text_scale)
	popup.modulate = text_color

	var label := popup.find_child("RichLabel") as RichTextLabel
	if label:
		label.clear()
		if icon_index >= 0:
			label.add_image(
				DAMAGE_TYPE_ICONS,         # full spritesheet
				16, 16,                    # display size
				Color.WHITE,
				INLINE_ALIGNMENT_CENTER,   # vertical align relative to text
				Rect2(icon_index * 32, 0, 32, 32)  # crop region
			)
		label.add_text(text)

	get_tree().current_scene.add_child(popup)

	var tween := get_tree().create_tween()
	tween.tween_property(popup, "position",
		global_position + DMG_POPUP_OFFSET + get_direction() * movement_multiplier, 0.5)

## Logarithmic scale: ~0.8 at 1 dmg, 1.0 around 5–10, grows slowly to 2.0 cap.
func _damage_to_scale(damage: float) -> float:
	return clampf(0.6 + log(maxf(damage, 1.0)) * 0.2, 0.8, 2.0)

func get_damage_icon(sprite_index: int) -> AtlasTexture:
	if sprite_index < 0:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = DAMAGE_TYPE_ICONS
	atlas.region = Rect2(sprite_index * 32, 0, 32, 32)
	return atlas

func get_direction() :
	return Vector2(randf_range(-1,1), -randf()) * 16

func _spawn(scene: PackedScene, hit_data: HitData = null) -> Node2D:
	if scene == null:
		push_warning("ParticleModule: tried to spawn a null scene.")
		return null
	var inst := scene.instantiate() 
	add_child(inst)
	print("Added child " + str(inst))
	if hit_data != null and inst.has_method("setup"):
		inst.setup(hit_data)
	if inst is GPUParticles2D:
		(inst as GPUParticles2D).emitting = true
	return inst

func spawn_particle(particle_scene : PackedScene) -> void :
	var inst = particle_scene.instantiate()
	add_child(inst)
	inst.emitting = true
	if not _active_particles.has(particle_scene):
		_active_particles[particle_scene] = []
	_active_particles[particle_scene].append(inst)

func remove_particle(particle_scene : PackedScene) -> void :
	if not _active_particles.has(particle_scene):
		return
	var instances: Array = _active_particles[particle_scene]
	if instances.size() > 0:
		instances[0].queue_free()
		instances.remove_at(0)
	if instances.is_empty():
		_active_particles.erase(particle_scene)

func emit_block_particles(hit_data: HitData = null) -> void:
	_spawn(block_particle, hit_data)

func emit_parry_particles(hit_data: HitData = null) -> void:
	_spawn(parry_particle, hit_data)

func emit_hit_particles(hit_data: HitData = null) -> void:
	_spawn(hit_effect_scene, hit_data)

func emit_level_up_particles() -> void:
	_spawn(level_up_particle)

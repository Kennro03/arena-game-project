extends Control
class_name DisplayModule

@export var _status_module: StatusEffectModule = null

@onready var compact_display: Control = %CompactDisplay

@onready var health_bar: TextureProgressBar = %HealthBar
@onready var shield_bar: TextureProgressBar = %ShieldBar
@onready var name_label: Label = %NameLabel
@onready var state_rich_text_label: RichTextLabel = %StateRichTextLabel
@onready var expand_button: TextureButton = %ExpandButton
@onready var status_effect_icons_container: HBoxContainer = %StatusEffectIconsContainer

const STATUS_ICON = preload("uid://d4rq68h801ac")

func update_healthBar(_health, _max_health) -> void :
	health_bar.max_value = _max_health
	health_bar.value = _health

func update_shieldBar(_shield, _max_shield) -> void :
	shield_bar.max_value = _max_shield
	shield_bar.value = _shield
	shield_bar.visible = _shield > 0.0

func set_healthbar_visibility(vis : bool)->void:
	health_bar.visible = vis

func hide_shieldBar() -> void :
	shield_bar.visible = !shield_bar.visible

func clear_status_icons() -> void :
	for icon in status_effect_icons_container.get_children() :
		icon.queue_free()

func link_to_unit(unit: BaseUnit) -> void:
	_status_module = unit.statusEffectModule
	clear_status_icons()
	_status_module.effect_applied_with_id.connect(_on_effect_applied)
	_status_module.effects_changed.connect(_on_effects_changed)
	for effect in _status_module.statusEffectsList:
		_add_icon(effect)

func _on_effect_applied(effect: StatusEffect) -> void:
	for icon in status_effect_icons_container.get_children():
		if (icon as StatusEffectIcon).effect == effect:
			return  
	_add_icon(effect)

func _on_effects_changed(_list) -> void:
	for icon in status_effect_icons_container.get_children():
		var status_icon := icon as StatusEffectIcon
		if status_icon.effect not in _status_module.statusEffectsList:
			status_icon.queue_free()

func _add_icon(effect: StatusEffect) -> void:
	#print("ADDING ICON FOR : " + effect.Status_effect_name)
	var icon := STATUS_ICON.instantiate() as StatusEffectIcon
	status_effect_icons_container.add_child(icon)
	icon.setup(effect)
	icon.offset_transform_scale = Vector2(0.5,0.5)

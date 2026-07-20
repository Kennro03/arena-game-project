extends Control
class_name StatusEffectIcon

@onready var icon: TextureRect = %StatusIconTextureRect
@onready var stacks_label: RichTextLabel = %StatusIconStacksLabel
@onready var duration_label: RichTextLabel = %StatusIconDurationLabel

var effect: StatusEffect = null

func setup(status_effect: StatusEffect) -> void:
	effect = status_effect
	icon.texture = effect.status_icon
	_refresh()

func _process(_delta: float) -> void:
	if effect == null or not is_instance_valid(effect):
		queue_free()
		return
	_refresh()

func _refresh() -> void:
	# only show stacks if effect has multiple stacks
	if effect.max_stacks > 1:
		stacks_label.visible = true
		stacks_label.text = str(effect.stacks)
	else:
		stacks_label.visible = false
	
	# only show duration if effect has a duration
	if effect.duration - effect.elapsed >= 10.0:
		duration_label.visible = true
		duration_label.text = "%.0f" % (effect.duration - effect.elapsed)
	elif effect.duration - effect.elapsed > 0.0:
		duration_label.visible = true
		duration_label.text = "%.1f" % (effect.duration - effect.elapsed)
	else:
		duration_label.visible = false

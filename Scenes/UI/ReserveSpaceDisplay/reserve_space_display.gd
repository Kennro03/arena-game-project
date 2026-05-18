extends Control
class_name ReserveSpaceDisplay

@onready var reserve_space_display: RichTextLabel = %ReserveSpaceDisplay

func _ready() -> void:
	update_display()
	Events.unit_added_to_reserve.connect(update_display.unbind(1))
	Events.unit_added_to_team.connect(update_display.unbind(1))
	Events.unit_recalled.connect(update_display.unbind(1))
	Events.unit_recruited.connect(update_display.unbind(1))
	Events.unit_removed.connect(update_display.unbind(1))

func update_display()->void:
	reserve_space_display.text = "Reserve : %d/%d" % [Player.reserve.size(),Player.reserve_size]

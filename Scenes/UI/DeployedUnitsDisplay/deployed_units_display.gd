extends Control
class_name DeployedUnitsDisplay

@onready var deployed_units_display: RichTextLabel = %DeployedUnitsDisplay

func _ready() -> void:
	update_display()
	Events.unit_deployed.connect(update_display.unbind(1))
	Events.unit_recalled.connect(update_display.unbind(1))
	Events.unit_removed.connect(update_display.unbind(1))

func update_display()->void:
	deployed_units_display.text = "Deployed Units : %d/%d" % [Player.team.size(),Player.team_size]

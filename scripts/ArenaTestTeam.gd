extends Resource
class_name ArenaTestTeam

@export var team_name: String = "Team 1"
@export var fighters: Array[UnitData] = []
# leave empty to use TEAM_COLORS[index] automatically
@export var override_color: Color = Color.TRANSPARENT

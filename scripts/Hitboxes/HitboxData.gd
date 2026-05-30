extends Resource
class_name HitboxData

enum Shape { CIRCLE, RECTANGLE, CONE }

@export var shape: Shape = Shape.CIRCLE
@export var size: Vector2 = Vector2(30, 30)  # radius for circle, extents for rect, (length, angle) for cone
@export var offset: Vector2 = Vector2.ZERO   # offset from spawn position
@export var duration: float = 0.1
@export var hit_check_interval: float = 0.1
@export var multi_hit: bool = false
#@export var team_filter: TeamFilter = null  # which teams it can hit, not implemented yet

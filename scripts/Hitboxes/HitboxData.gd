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

@export_group("Attack Visual")
@export var attack_frames: SpriteFrames = null      # null = no visual
@export var attack_animation: String = "default"
@export var attack_modulate: Color = Color.WHITE
@export var visual_lifetime: float = -1.0           # -1 = auto from animation length
@export var visual_offset: Vector2 = Vector2.ZERO   # additional offset from hitbox pos
@export var visual_scale_mode: AttackVisual.ScaleMode = AttackVisual.ScaleMode.FIT_TO_SIZE
@export var spawn_visual_on_hitbox_create: bool = true  # false = caller manages visual manually

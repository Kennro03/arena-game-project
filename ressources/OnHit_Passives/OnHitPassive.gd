extends Resource
class_name OnHitPassive

@export var onhit_passive_name : String
@export var onhit_passive_ID : String
@export var onhit_passive_description : String
@export var onhit_passive_icon : Texture2D = PlaceholderTexture2D.new()

func on_hit(_hit: HitData) -> void:
	pass

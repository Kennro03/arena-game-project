extends Resource
class_name SkillEffect

func apply(_caster: Node2D, _context: Dictionary = {}):
	# context is optional extra info (direction, point of impact, etc.)
	pass


func modify_hit(_caster: Node2D, _hit_result: HitData, _context: Dictionary = {}) -> HitData:
	# context is optional extra info (direction, point of impact, etc.)
	return 

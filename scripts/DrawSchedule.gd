extends Resource
class_name DrawSchedule

enum DrawType { PASSIVE_SKILL, ACTIVE_SKILL, STAT_BONUS, ITEM, UNIT, CHOICE, NONE }

# returns what type of draw to give at a given level
static func get_draw_type(level: int) -> DrawType:
	if level % 5 == 0:
		return DrawType.ACTIVE_SKILL
	elif level % 3 == 0:
		return DrawType.PASSIVE_SKILL
	else:
		return DrawType.NONE  # or null if no draw this level

static func has_draw(level: int) -> bool:
	return level % 3 == 0 or level % 5 == 0

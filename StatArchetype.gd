extends Resource
class_name StatArchetype

@export var archetype_name: String = "Balanced"

# each entry is a stat and its relative weight among prioritized stats
# example physical: {STRENGTH: 3, DEXTERITY: 2, ENDURANCE: 2}
@export var stat_weights: Dictionary = {}  # Stats.Attributes -> float

# what fraction of total points goes to prioritized stats vs random others
# 1.0 = all points in stat_weights, 0.5 = half focused half totally random
@export var focus_ratio: float = 1.0

#Also add a bool to chose if the unfocused points get spent at total random or only among unfocused stats
static func physical() -> StatArchetype:
	var a := StatArchetype.new()
	a.archetype_name = "Physical"
	a.stat_weights = {
		Stats.Attributes.STRENGTH: 1.0,
		Stats.Attributes.DEXTERITY: 1.0,
		Stats.Attributes.ENDURANCE: 1.0,
	}
	a.focus_ratio = 0.8
	return a

static func ethereal() -> StatArchetype:
	var a := StatArchetype.new()
	a.archetype_name = "Ethereal"
	a.stat_weights = {
		Stats.Attributes.INTELLECT: 1.0,
		Stats.Attributes.ATTUNEMENT: 1.0,
		Stats.Attributes.FAITH: 1.0,
	}
	a.focus_ratio = 0.8
	return a

# Add to StatArchetype — parses TRRS strings and assigns random stats
static func from_trrs(trrs_string: String) -> StatArchetype:
	var a := StatArchetype.new()
	
	var parts_str := trrs_string.trim_prefix("TRRS ").trim_prefix("BRS ")
	var segments := parts_str.split("-")
	
	var focused_ratios: Dictionary = {}  # "M"/"S"/"T" -> float
	var remaining_ratio := 0.0
	
	for seg in segments:
		var num_str := ""
		var role := ""
		for c in seg:
			if c.is_valid_int():
				num_str += c
			else:
				role += c
		var ratio := float(num_str) / 100.0
		if role == "R":
			remaining_ratio = ratio
		else:
			focused_ratios[role] = ratio
	
	# randomly assign stats to roles
	var all_attrs := Stats.Attributes.values().duplicate()
	all_attrs.shuffle()
	var attr_index := 0
	
	# track role -> assigned stat for name building
	var role_to_stat: Dictionary = {}
	
	for role in ["M", "S", "T"]:
		if focused_ratios.has(role) and attr_index < all_attrs.size():
			var chosen_attr: Stats.Attributes = all_attrs[attr_index]
			a.stat_weights[chosen_attr] = focused_ratios[role]
			role_to_stat[role] = chosen_attr
			attr_index += 1
	
	a.focus_ratio = 1.0 - remaining_ratio
	
	# build name from actual chosen stats
	var name_parts: Array[String] = []
	for role in ["M", "S", "T"]:
		if role_to_stat.has(role):
			var stat_name : String = Stats.Attributes.keys()[role_to_stat[role]]
			var percent := int(focused_ratios[role] * 100)
			name_parts.append("%d%s" % [percent, stat_name.substr(0, 3).to_upper()])
	if remaining_ratio > 0:
		name_parts.append("%dR" % int(remaining_ratio * 100))
	
	a.archetype_name = "TRRS %s" % "-".join(name_parts)
	return a

static func random_archetype() -> StatArchetype:
	var a := StatArchetype.new()
	a.archetype_name = "Random"
	a.stat_weights = {}  # empty = fully random
	a.focus_ratio = 0.0
	return a

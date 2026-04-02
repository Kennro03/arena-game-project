extends Tooltip
class_name WeaponToolTip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	text_label.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func setup(weapon: Weapon) -> void:
	add_weapon_name(weapon)
	add_weapon_type(weapon)
	#add_weapon_description(weapon)
	add_weapon_passives(weapon)
	add_weapon_stats(weapon)
	add_weapon_stats_scalings(weapon)
	
	pass

func add_weapon_name(weapon: Weapon) -> void:
	var rarity_color := {
		Item.Rarity.COMMON: "white",
		Item.Rarity.UNCOMMON: "green",
		Item.Rarity.RARE: "cyan",
		Item.Rarity.EPIC: "purple",
		Item.Rarity.LEGENDARY: "red",
		Item.Rarity.CURSED: "dark_gray"
	}
	var color: String = rarity_color[weapon.rarity]
	text_label.append_text("[center][font_size=10][color=%s]%s[/color][/font_size][/center]" % [color, weapon.item_name])
	text_label.newline()

func add_weapon_type(weapon: Weapon) -> void :
	var weapon_type: String = weapon.WeaponTypeEnum.keys()[weapon.weaponType].capitalize()
	var weapon_category: String = weapon.WeaponCategoryEnum.keys()[weapon.weaponCategory].capitalize()
	var line: String = "[i][color=light_gray]%s - %s[/color][/i]" % [weapon_type,weapon_category]
	text_label.append_text(line)
	text_label.newline()

func add_weapon_description(weapon: Weapon) -> void :
	var item_description: String = weapon.description
	var line: String = "%s" % [item_description]
	text_label.append_text(line)
	text_label.newline()

func add_weapon_stats(weapon: Weapon) -> void:
	var stats := {
		"Damage": weapon.base_damage,
		"Attack Speed": weapon.base_attack_speed,
		"Attack Range": weapon.base_attack_range,
		"Knockback": weapon.base_knockback,
	}
	text_label.append_text("[b]Weapon Stats :[/b]")
	text_label.newline()
	for stat_name in stats :
		text_label.append_text("%s - %s" % [stat_name,stats[stat_name]])
		text_label.newline()

func add_weapon_passives(weapon: Weapon) -> void:
	if weapon.statChanges.size() > 0 :
		text_label.append_text("[b]Stat buffs :[/b]")
		text_label.newline()
	for stat_change in weapon.statChanges :
		var stat_name: String = Stats.BuffableStats.keys()[stat_change.stat].capitalize()
		text_label.append_text("%s %s" % [stat_change.buff_amount, stat_name])
		text_label.newline()
	if weapon.onHitPassives.size() > 0 :
		text_label.append_text("[b]On-hit Passives :[/b]")
		text_label.newline()
	for passive in weapon.onHitPassives :
		text_label.append_text("%s : %s" % [passive.onhit_passive_name,passive.onhit_passive_description])
		text_label.newline()

func add_weapon_stats_scalings(weapon: Weapon) -> void:
	var stats_scalings := {
		"Damage": weapon.damage_scalings,
		"Attack Speed": weapon.attack_speed_scalings,
		"Attack Range": weapon.attack_range_scalings,
		"Knockback": weapon.knockback_scalings,
	}
	if stats_scalings.values().any(func(arr): return not arr.is_empty()) :
		text_label.append_text("[b]Weapon Scalings :[/b]")
		text_label.newline()
		for stat_scaling_name in stats_scalings :
			if stats_scalings[stat_scaling_name] != [] :
				text_label.append_text("%s - " % [stat_scaling_name])
				for stat_scaling in stats_scalings[stat_scaling_name] :
					text_label.append_text("%s" % [stat_scaling_name])
					text_label.newline()
			text_label.newline()

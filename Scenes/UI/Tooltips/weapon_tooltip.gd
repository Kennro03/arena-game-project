extends Tooltip
class_name WeaponToolTip

var test_dagger := preload("res://ressources/Weapons/testdagger.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	text_label.text = ""
	var stat_buff : StatBuff = StatBuff.new(Stats.BuffableStats.STRENGTH,5,StatBuff.BuffType.ADD) 
	#test_dagger.statChanges.append(stat_buff)
	setup(test_dagger)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func setup(weapon: Weapon) -> void:
	add_weapon_name(weapon)
	add_weapon_type(weapon)
	add_weapon_description(weapon)
	add_weapon_passives(weapon)
	add_weapon_stats(weapon)
	
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

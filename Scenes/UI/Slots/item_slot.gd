extends Slot
class_name ItemSlot

const PALETTE_SWAP_MATERIAL = preload("uid://dq56kvtjp86e0")

enum SlotContext { INVENTORY, UNIT_GEAR, REWARD, SHOP, DISPLAY }

var slot_context: SlotContext = SlotContext.DISPLAY
var owner_unit: BaseUnit = null  

@export var item: Item = null
@onready var drag_visual: SlotDragVisual = $DragVisual

@onready var rich_text_label: RichTextLabel = $TextLabel
@onready var text_label: RichTextLabel = $TextLabel

func _ready() -> void:
	set_item(load("uid://dal5rgfowl103"))
	pass

func set_item(_item: Item) -> void:
	item = _item
	set_visuals()
	if _item != null :
		drag_visual.enabled = true
	else : 
		drag_visual.enabled = false

func set_texture() -> void:
	var icon := get_icon()
	icon_sprite.texture = icon 
	icon_sprite.visible = icon != null
	
	if item is Weapon or item is RangedWeapon :
		var color_palette : Texture2D = item.get_color_palette()
		
		icon_sprite.material = PALETTE_SWAP_MATERIAL.duplicate(false)
		
		if color_palette != null:
			icon_sprite.material.set_shader_parameter("original_palette", preload("uid://dv8kdjtdqrghu"))
			icon_sprite.material.set_shader_parameter("new_palette", color_palette)
			icon_sprite.material.set_shader_parameter("colors_count", 5)
		else:
			printerr("Item %s has no weaponColorPalette" % item.item_name)
	else : 
		icon_sprite.material = null

func get_icon() -> Texture2D:
	return item.icon if item else null

func get_border() -> Texture2D:
	return item.item_borders[item.rarity] if item else EMPTY_BORDER

func _to_string() -> String:
	return item.item_name if item else "empty"

func set_label_text(new_text: String) -> void :
	rich_text_label.append_text(new_text)

func _make_custom_tooltip(_for_text: String) -> Object:
	if item == null:
		return null
	
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.custom_minimum_size = Vector2(150, 30)
	
	if item.item_type == Item.ItemType.WEAPON:
		_add_item_name(rtl, item)
		_add_weapon_type(rtl, item)
		_add_weapon_description(rtl, item)
		_add_weapon_stats(rtl, item)
		_add_weapon_stats_scalings(rtl, item)
		_add_weapon_passives(rtl, item)
	elif item.item_type == Item.ItemType.ACCESSORY:
		_add_item_name(rtl, item)
		_add_item_type(rtl, item)
		_add_item_description(rtl, item)
		_add_accessory_stat_buffs(rtl, item)
	elif item.item_type == Item.ItemType.ARMOR:
		_add_item_name(rtl, item)
	else :
		_add_item_name(rtl, item)
		_add_item_type(rtl, item)
		_add_item_description(rtl, item)
	
	return rtl

func _add_item_name(_rtl: RichTextLabel, _item: Item) -> void:
	var rarity_color := {
		Item.Rarity.COMMON: "white",
		Item.Rarity.UNCOMMON: "green",
		Item.Rarity.RARE: "cyan",
		Item.Rarity.EPIC: "purple",
		Item.Rarity.LEGENDARY: "red",
		Item.Rarity.CURSED: "dark_gray"
	}
	var color: String = rarity_color[_item.rarity]
	_rtl.append_text("[center][font_size=24][color=%s]%s[/color][/font_size][/center]" % [color, _item.item_name])
	_rtl.newline()

func _add_item_type(_rtl: RichTextLabel, _item: Item) -> void :
	var type_name: String = _item.ItemType.keys()[_item.item_type].capitalize()
	var line: String = "[color=light_gray]%s[/color]" % [type_name]
	_rtl.append_text(line)
	_rtl.newline()

func _add_item_description(_rtl: RichTextLabel, _item: Item) -> void :
	var item_description: String = _item.description
	var line: String = "%s" % [item_description]
	_rtl.append_text(line)
	_rtl.newline()

func _add_weapon_type(_rtl: RichTextLabel, weapon: Weapon) -> void :
	var weapon_type: String = weapon.WeaponTypeEnum.keys()[weapon.weaponType].capitalize()
	var weapon_category: String = weapon.WeaponCategoryEnum.keys()[weapon.weaponCategory].capitalize()
	var line: String = "[color=light_gray]%s - %s[/color]" % [weapon_type,weapon_category]
	_rtl.append_text(line)
	_rtl.newline()

func _add_weapon_description(_rtl: RichTextLabel, weapon: Weapon) -> void :
	var item_description: String = weapon.description
	var line: String = "%s" % [item_description]
	_rtl.append_text(line)
	_rtl.newline()

func _add_weapon_stats(_rtl: RichTextLabel, weapon: Weapon) -> void:
	var stats := {
		"Damage": weapon.current_damage,
		"Attack Speed": weapon.current_attack_speed,
		"Attack Range": weapon.current_attack_range,
		"Knockback": weapon.current_knockback,
	}
	_rtl.append_text("[center]Weapon Stats :[/center]")
	_rtl.newline()
	for stat_name in stats :
		_rtl.append_text("%s : %s" % [stat_name,stats[stat_name]])
		_rtl.newline()

func _add_weapon_passives(_rtl: RichTextLabel, weapon: Weapon) -> void:
	if weapon.statChanges.size() > 0 :
		_rtl.append_text("[center]Stat buffs :[/center]")
		_rtl.newline()
	for stat_change in weapon.statChanges :
		var stat_name: String = Stats.BuffableStats.keys()[stat_change.stat].capitalize()
		_rtl.append_text("%s %s" % [stat_change.buff_amount, stat_name])
		_rtl.newline()
	if weapon.onHitPassives.size() > 0 :
		_rtl.append_text("[center]On-hit Passives :[/center]")
		_rtl.newline()
	for passive in weapon.onHitPassives :
		_rtl.append_text("%s : %s" % [passive.onhit_passive_name,passive.onhit_passive_description])
		_rtl.newline()

func _add_weapon_stats_scalings(_rtl: RichTextLabel, weapon: Weapon) -> void:
	var stats_scalings := {
		"Damage": weapon.damage_scalings,
		"Attack Speed": weapon.attack_speed_scalings,
		"Attack Range": weapon.attack_range_scalings,
		"Knockback": weapon.knockback_scalings,
	}
	if stats_scalings.values().any(func(arr): return not arr.is_empty()) :
		_rtl.append_text("[center]Weapon Scalings :[/center]")
		_rtl.newline()
		for stat_scaling_name in stats_scalings :
			if stats_scalings[stat_scaling_name] != [] :
				_rtl.append_text("%s - " % [stat_scaling_name])
				for stat_scaling in stats_scalings[stat_scaling_name] :
					_rtl.append_text("%s" % [stat_scaling_name])
					_rtl.newline()
			_rtl.newline()

func _add_accessory_stat_buffs(_rtl: RichTextLabel, _item: Item) -> void:
	var stat_changes : Array[Buff] = _item.statChanges
	if stat_changes.size() > 0 :
		_rtl.append_text("[center]Stat changes : [/center]")
	for b in stat_changes :
		_rtl.newline() 
		var stat_changed :int= b.stat_index
		var stat_name : String = Stats.BuffableStats.keys()[stat_changed].capitalize()
		var stat_change_color : Color = Stats.stat_text_colors.get(stat_changed, Color.WHITE)
		var color_hex : String = "#" + stat_change_color.to_html(false)
		if b.buff_type == Buff.BuffType.ADD:
			if b.buff_amount > 0:
				_rtl.append_text("[color=%s]+%s %s[/color]" % [color_hex, b.buff_amount, stat_name])
			elif b.buff_amount < 0:
				_rtl.append_text("[color=%s]%s %s[/color]" % [color_hex, b.buff_amount, stat_name])
		if b.buff_type == Buff.BuffType.MULTIPLY:
			var percent := snappedf((b.buff_amount - 1.0) * 100.0, 0.1)
			if b.buff_amount > 1.0:
				_rtl.append_text("[color=%s]+%s%% %s[/color]" % [color_hex, percent, stat_name])
			elif b.buff_amount < 1.0:
				_rtl.append_text("[color=%s]%s%% %s[/color]" % [color_hex, percent, stat_name])

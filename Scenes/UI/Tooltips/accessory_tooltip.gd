extends ItemToolTip
class_name AccessoryTooltip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func setup(item: Item) -> void:
	super.setup(item)
	text_label.newline()
	add_item_stat_buffs(item)
	pass

func add_item_stat_buffs(item: Item) -> void:
	var stat_changes : Array[StatBuff] = item.statChanges
	if stat_changes.size() > 0 :
		text_label.append_text("Stat changes : ")
	for b in stat_changes :
		text_label.newline() 
		var stat_changed := b.stat
		var stat_name : String = Stats.BuffableStats.keys()[stat_changed].capitalize()
		var stat_change_color : Color = Stats.stat_text_colors.get(stat_changed, Color.WHITE)
		var color_hex : String = "#" + stat_change_color.to_html(false)
		if b.buff_type == StatBuff.BuffType.ADD:
			if b.buff_amount > 0:
				text_label.append_text("[color=%s]+%s %s[/color]" % [color_hex, b.buff_amount, stat_name])
			elif b.buff_amount < 0:
				text_label.append_text("[color=%s]%s %s[/color]" % [color_hex, b.buff_amount, stat_name])
		if b.buff_type == StatBuff.BuffType.MULTIPLY:
			var percent := snappedf((b.buff_amount - 1.0) * 100.0, 0.1)
			if b.buff_amount > 1.0:
				text_label.append_text("[color=%s]+%s%% %s[/color]" % [color_hex, percent, stat_name])
			elif b.buff_amount < 1.0:
				text_label.append_text("[color=%s]%s%% %s[/color]" % [color_hex, percent, stat_name])

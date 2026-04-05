extends Tooltip
class_name ItemToolTip

var test_dagger := preload("uid://dal5rgfowl103")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	text_label.text = ""
	setup(test_dagger)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func setup(item: Item) -> void:
	add_item_name(item)
	text_label.newline()
	add_item_type(item)
	text_label.newline()
	add_item_description(item)
	pass

func add_item_name(item: Item) -> void:
	var rarity_color := {
		Item.Rarity.COMMON: "white",
		Item.Rarity.UNCOMMON: "green",
		Item.Rarity.RARE: "cyan",
		Item.Rarity.EPIC: "purple",
		Item.Rarity.LEGENDARY: "red",
		Item.Rarity.CURSED: "dark_gray"
	}
	var color: String = rarity_color[item.rarity]
	text_label.append_text("[center][font_size=10][color=%s]%s[/color][/font_size][/center]" % [color, item.item_name])

func add_item_type(item: Item) -> void :
	var type_name: String = item.ItemType.keys()[item.item_type].capitalize()
	var line: String = "[i][color=light_gray]%s[/color][/i]" % [type_name]
	text_label.append_text(line)

func add_item_description(item: Item) -> void :
	var item_description: String = item.description
	var line: String = "%s" % [item_description]
	text_label.append_text(line)

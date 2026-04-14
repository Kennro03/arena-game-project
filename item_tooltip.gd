extends Tooltip
class_name ItemToolTip

@export var item : Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	text_label.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func setup(_item: Item) -> void:
	add_item_name(_item)
	text_label.newline()
	add_item_type(_item)
	text_label.newline()
	add_item_description(_item)
	pass

func add_item_name(_item: Item) -> void:
	var rarity_color := {
		Item.Rarity.COMMON: "white",
		Item.Rarity.UNCOMMON: "green",
		Item.Rarity.RARE: "cyan",
		Item.Rarity.EPIC: "purple",
		Item.Rarity.LEGENDARY: "red",
		Item.Rarity.CURSED: "dark_gray"
	}
	var color: String = rarity_color[_item.rarity]
	text_label.append_text("[center][font_size=10][color=%s]%s[/color][/font_size][/center]" % [color, _item.item_name])

func add_item_type(_item: Item) -> void :
	var type_name: String = _item.ItemType.keys()[_item.item_type].capitalize()
	var line: String = "[i][color=light_gray]%s[/color][/i]" % [type_name]
	text_label.append_text(line)

func add_item_description(_item: Item) -> void :
	var item_description: String = _item.description
	var line: String = "%s" % [item_description]
	text_label.append_text(line)

extends Item
class_name GoldReward

static var gold_icon := preload("res://ressources/Sprites/Icons/Map/shop_icon.png")

func _init(amount: int = 0) -> void:
	item_type = Item.ItemType.MISC
	rarity = Item.Rarity.COMMON
	item_id = UIDGenerator.generate("gold_reward")
	icon = gold_icon
	set_amount(amount)

func set_amount(amount: int) -> void:
	value = amount
	item_name = "%d Gold" % amount
	description = "Collect %d gold." % amount

func collect() -> void:
	Player.gold += value

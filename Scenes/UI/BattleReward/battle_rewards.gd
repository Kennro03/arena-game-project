extends Control
class_name BattleRewards

@export var gold_reward : int = 0
@export var item_reward : Array[Item] = [] 

@onready var reward_container: GridContainer = %RewardContainer
@onready var close_button: Button = %CloseButton

const ITEM_SLOT_SCENE = preload("uid://dnm02uo4msg2e")

func _ready() -> void :
	clear_rewards()
	add_gold_reward()

func clear_rewards() -> void : 
	for r in reward_container.get_children() :
		r.queue_free()

func add_gold_reward() -> void :
	var gold_item := GoldReward.new(gold_reward)
	var gold_slot := _add_reward_slot(gold_item, true)  
	gold_slot.set_label_text(gold_item.item_name)

func _on_close_button_pressed() -> void:
	queue_free()

func _add_reward_slot(item: Item, is_gold: bool) -> ItemSlot:
	var slot := ITEM_SLOT_SCENE.instantiate() as ItemSlot
	slot.slot_clicked.connect(func(s, _button):
		if is_gold:
			(s.item as GoldReward).collect()
		else:
			Player.add_item_to_inventory(s.item)
		s.set_item(null)
		s.disabled = true)
	reward_container.add_child(slot)
	slot.set_item(item)
	return slot

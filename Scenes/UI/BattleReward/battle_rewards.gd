extends Control
class_name BattleRewards

@export var gold_reward : int = 0
@export var item_reward : Array[Item] = [] 

@export var slot_size : Vector2 = Vector2(32.0,32.0)
@export var slot_font_size : int = 8

@onready var reward_container: GridContainer = %RewardContainer
@onready var close_button: Button = %CloseButton

const ITEM_SLOT_SCENE = preload("uid://dnm02uo4msg2e")

func _ready() -> void :
	update_rewards()

func update_rewards() -> void :
	clear_rewards()
	add_gold_reward()
	add_item_rewards()
	print("Total battle rewards = [")
	if gold_reward > 0 :
		print(str(gold_reward)+ " gold\n")
	for item in item_reward :
		print(item.item_name + "\n")
	print("]")

func clear_rewards() -> void : 
	for r in reward_container.get_children() :
		r.queue_free()

func add_gold_reward() -> void :
	if gold_reward <= 0 :
		return
	var gold_item := GoldReward.new(gold_reward)
	var gold_slot := _add_reward_slot(gold_item, true)  
	gold_slot.set_label_text(gold_item.item_name, slot_font_size)

func add_item_rewards() -> void :
	for i in item_reward :
		var item_slot := _add_reward_slot(i, false)  
		item_slot.set_label_text(i.item_name, slot_font_size)

func _on_close_button_pressed() -> void:
	Player.return_to_previous_scene()

func _add_reward_slot(item: Item, is_gold: bool) -> ItemSlot:
	var slot := ITEM_SLOT_SCENE.instantiate() as ItemSlot
	slot.custom_minimum_size = slot_size
	#slot.is_inventory_slot                ##disable dragging 
	 
	if slot.has_node("DragVisual"):
		slot.get_node("DragVisual").enabled = false
	
	slot.slot_clicked.connect(func(s, _button):
		if _button != MOUSE_BUTTON_LEFT:
			return
		if s.item == null:
			return
		if is_gold:
			(s.item as GoldReward).collect()
			slot.queue_free()
		else:
			Player.add_item_to_inventory(s.item)
			slot.queue_free()
		)
	reward_container.add_child(slot)
	slot.set_item(item)
	return slot

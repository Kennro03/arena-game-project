extends Control
class_name InspectMenu

@warning_ignore_start("unused_signal")
signal menu_opened(target)
signal menu_closed(target)
@warning_ignore_restore("unused_signal")

const MOUSE_OFFSET : Vector2 = Vector2(8, 8) 
const INSPECT_MENU_BUTTON := preload("res://Scenes/UI/InspectMenu/inspect_menu_button.tscn")

@onready var menu_button_vbox: VBoxContainer = %MenuButtonVbox

var target

func _ready() -> void:
	if !target : 
		printerr("Inspect menu has no target ! Give it one before spawning")
		return 
	
	clear_button_list()
	global_position = get_viewport().get_mouse_position() + MOUSE_OFFSET
	load_button_list()

func clear_button_list() -> void :
	for c in menu_button_vbox.get_children() :
		c.queue_free()

func load_button_list() -> void :
	if target is BaseUnit:
		load_unit_inspect_buttons()
	if target is UnitSlot:
		load_unit_slot_inspect_buttons()
	if target is ItemSlot:
		if target is ShopSlot :
			load_shop_slot_inspect_buttons()
		else :
			load_item_slot_inspect_buttons()

func load_unit_inspect_buttons() -> void :
	#load buttons regarding live units
	var _unit := target as BaseUnit
	_add_button("Inspect unit", func():
		Events.open_unit_info_requested.emit(_unit)
		)
	
	var battle_state := BattleManager.get_state(self)
	
	if _unit in Player.deployed_units and battle_state == BattleManager.LevelState.SPAWNING :
		_add_button("Send unit to reserve", func():
			Player.recall_unit(_unit)
			close()
			)
	pass

func load_unit_slot_inspect_buttons() -> void :
	#load buttons regarding unitData slots
	var _slot := target as UnitSlot
	if _slot._unit_data == null :
		close()
	
	_add_button("Remove Unit", func():
		if is_instance_valid(_slot) :
			Player.remove_unit(_slot._unit_data)
			close()
		)
	pass

func load_item_slot_inspect_buttons() -> void :
	#load buttons regarding item slots
	var _slot := target as ItemSlot
	if _slot.item == null :
		close()
	
	match _slot.slot_context:
		ItemSlot.SlotContext.INVENTORY:
			_add_button("Inspect Item", func():
				if is_instance_valid(_slot) :
					pass
					## Need to implement new unit/item info UI
					Events.open_item_info_requested.emit(_slot.item)
				)
			_add_button("Discard", func():
				if is_instance_valid(_slot):
					Player.remove_item_from_inventory(_slot.item)
				close())
			print("Current scene = " + str(Player.current_scene) + " shop scene = uid://n6ib3torqc3t")
			if Player.current_scene == "uid://n6ib3torqc3t" :
				_add_button("Sell", func():
					if is_instance_valid(_slot):
						Player.sell_item(_slot.item)
					close())
		ItemSlot.SlotContext.UNIT_GEAR:
			if is_instance_valid(_slot.owner_unit):
				_add_button("Inspect Item", func():
					if is_instance_valid(_slot) :
						Events.open_item_info_requested.emit(_slot.item)
					)
				if _slot.owner_unit in Player.deployed_units and _slot.item.item_id != _slot.owner_unit.default_weapon.item_id :
					_add_button("Unequip", func():
						if is_instance_valid(_slot) and is_instance_valid(_slot.owner_unit):
							_unequip_from_unit(_slot)
							pass
						close())
		ItemSlot.SlotContext.REWARD:
			pass  

func load_shop_slot_inspect_buttons() -> void :
	#load buttons regarding shop slots
	var _slot := target as ItemSlot
	if _slot.item == null :
		close()
	_add_button("Inspect Item", func():
		Events.open_item_info_requested.emit(_slot.item)
		#UnitInfoPanel.open(slot.item)
		)
	
	_add_button("Buy [%d]" % _slot.item.value, func():
		if _slot.cost <= Player.gold :
			Player.gold -= _slot.cost
			Player.add_to_inventory(_slot.item)
			close())

func _add_button(label: String, action: Callable) -> void:
	var button := INSPECT_MENU_BUTTON.instantiate() as InspectMenuButton
	button.setup(label, action)
	menu_button_vbox.add_child(button)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("CancelInspectMenu"):
		close()

func close() -> void:
	queue_free()

func _unequip_from_unit(slot: ItemSlot) -> void:
	var unit := slot.owner_unit
	if slot.item is Weapon :
		unit.equip(unit.default_weapon)
		Player.add_item_to_inventory(slot.item)
	elif slot.item is Armor:
		unit.armor.remove_owner_buffs(unit.stats)
		unit.armor = null
		Player.add_item_to_inventory(slot.item)
	elif slot.item is Accessory:
		unit.unequip_accessory(slot.item as Accessory)
		Player.add_item_to_inventory(slot.item)

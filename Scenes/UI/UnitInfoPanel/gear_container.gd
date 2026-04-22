extends MarginContainer
class_name GearContainer

@export var gear : Item = null

@onready var icon_container: VBoxContainer = %IconContainer
@onready var gear_name_label: Label = %GearNameLabel
@onready var stats_rich_text_label: RichTextLabel = %StatsRichTextLabel
@onready var passives_rich_text_label: RichTextLabel = %PassivesRichTextLabel

const ARMOR_SLOT = preload("uid://bpkurgfb4csud")
const WEAPON_SLOT = preload("uid://cr0ku2232m77j")
const ACCESSORY_SLOT = preload("uid://dd2psrpeofhbi")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if gear == null : 
		printerr("No gear.")
		return
	add_gear_slot()
	set_gear_name()
	set_item_stats()
	set_item_passives()

func add_gear_slot() -> void :
	match gear.item_type :
		Item.ItemType.WEAPON :
			var wep_slot : WeaponSlot = WEAPON_SLOT.instantiate()
			
			icon_container.add_child(wep_slot)
			icon_container.move_child(wep_slot,0)
			wep_slot.set_item(gear) 
			wep_slot.slot_context = ItemSlot.SlotContext.UNIT_GEAR
			wep_slot.drag_visual.enabled = false
		
		Item.ItemType.ARMOR :
			var armor_slot : ArmorSlot = ARMOR_SLOT.instantiate()
			
			icon_container.add_child(armor_slot)
			icon_container.move_child(armor_slot,0)
			armor_slot.set_item(gear) 
			armor_slot.slot_context = ItemSlot.SlotContext.UNIT_GEAR
			armor_slot.drag_visual.enabled = false
			
		
		Item.ItemType.ACCESSORY :
			var acc_slot : AccessorySlot = ACCESSORY_SLOT.instantiate()
			
			icon_container.add_child(acc_slot)
			icon_container.move_child(acc_slot,0)
			acc_slot.set_item(gear) 
			acc_slot.slot_context = ItemSlot.SlotContext.UNIT_GEAR
			acc_slot.drag_visual.enabled = false
		
		_:
			printerr("Gear is unknown.")

func set_gear_name() -> void :
	if gear and gear.item_name :
		gear_name_label.text = gear.item_name

func set_item_stats() -> void :
	if gear == null : 
		return
	stats_rich_text_label.clear()
	match gear.item_type :
		Item.ItemType.WEAPON :
			var wep := gear as Weapon
			wep.recalculate_stats()
			## could add a text indicator for the value given by each scaling
			stats_rich_text_label.append_text( "Atk damage : %s (+%s) " % [wep.current_damage,wep.current_damage-wep.base_damage])
			stats_rich_text_label.append_text("\nAtk speed : %s (+%s)" % [wep.current_attack_speed,wep.current_attack_speed-wep.base_attack_speed])
			stats_rich_text_label.append_text("\nAtk range : %s (+%s)" % [wep.current_attack_range,wep.current_attack_range-wep.base_attack_range])
			stats_rich_text_label.append_text("\nKnockback : %s (+%s)" % [wep.current_knockback,wep.current_knockback-wep.base_knockback])
			if wep.statChanges != [] :
				stats_rich_text_label.append_text("\nStat boosts : ") 
				for buff in wep.statChanges :
					stats_rich_text_label.append_text("\n%s " % [Stats.BuffableStats.keys()[buff.stat]])
					if buff.buff_type == StatBuff.BuffType.ADD :
						if buff.buff_amount > 0 :
							stats_rich_text_label.append_text("+" +str(buff.buff_amount))
						else :
							stats_rich_text_label.append_text(str(buff.buff_amount))
					else : 
						if buff.buff_amount > 1 :
							stats_rich_text_label.append_text("+" +str((buff.buff_amount-1)*100)+"%")
						else :
							stats_rich_text_label.append_text(str((buff.buff_amount-1)*100)+"%")
		
		Item.ItemType.ARMOR :
			var armor := gear as Armor
			if armor.statChanges != [] :
				stats_rich_text_label.append_text("\nStat buffs : ") 
			for buff in armor.statChanges :
				stats_rich_text_label.append_text("\n%s " % [Stats.BuffableStats.keys()[buff.stat]])
				if buff.buff_type == StatBuff.BuffType.ADD :
					if buff.buff_amount > 0 :
						stats_rich_text_label.append_text("+" +str(buff.buff_amount))
					else :
						stats_rich_text_label.append_text(str(buff.buff_amount))
				else : 
					if buff.buff_amount > 1 :
						stats_rich_text_label.append_text("+" +str((buff.buff_amount-1)*100)+"%")
					else :
						stats_rich_text_label.append_text(str((buff.buff_amount-1)*100)+"%")
		
		Item.ItemType.ACCESSORY :
			var acc := gear as Accessory
			if acc.statChanges != [] :
				stats_rich_text_label.append_text("\nStat buffs : ") 
			for buff in acc.statChanges :
				stats_rich_text_label.append_text("\n%s " % [Stats.BuffableStats.keys()[buff.stat]])
				if buff.buff_type == StatBuff.BuffType.ADD :
					if buff.buff_amount > 0 :
						stats_rich_text_label.append_text("+" +str(buff.buff_amount))
					else :
						stats_rich_text_label.append_text(str(buff.buff_amount))
				else : 
					if buff.buff_amount > 1 :
						stats_rich_text_label.append_text("+" +str((buff.buff_amount-1)*100)+"%")
					else :
						stats_rich_text_label.append_text(str((buff.buff_amount-1)*100)+"%")
		
		_:
			printerr("Gear is unknown.")

func set_item_passives() -> void :
	passives_rich_text_label.clear()

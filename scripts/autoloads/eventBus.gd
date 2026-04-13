extends Node
class_name EventBus

@warning_ignore_start("unused_signal")

# UI related
signal tooltip_requested(tip: Tooltip)
signal tooltip_cleared(tip: Tooltip)
signal open_unit_info_requested(unit: BaseUnit)
signal open_unit_slot_info_requested(unit_data: UnitData)
signal open_item_info_requested(item: Item)

#economy related
signal gold_gained(value: int)
signal gold_lost(value: int)
signal gold_changed(new_total: int)

#item related
signal item_added(item: Item)
signal item_removed(item: Item)
signal item_sold(item: Item)
signal item_equipped(item: Item)
signal item_unequipped(item: Item)

# Unit related
signal unit_recalled(unit: BaseUnit)            # sent from field to reserve
signal unit_deployed(unit: BaseUnit)            # any unit spawned on field
signal unit_deployment_failed(reason: String)   # spawning unit failed
signal unit_recruited(unit: UnitData)           # added to reserve for the first time
signal unit_removed(unit: UnitData)             # permadeath
signal unit_promoted(unit: UnitData)            # levelup, class change, etc.
signal unit_added_to_team(unit: UnitData)       # added to team from reserve
signal unit_removed_from_team(unit: UnitData)   # added to reserve from team (non-death)
signal unit_added_to_reserve(unit: UnitData)    
signal unit_removed_from_reserve(unit: UnitData)

# Slot related
signal slot_hovered(slot: Slot)
signal slot_drag_started(slot: Slot)
signal slot_drag_ended(slot: Slot, screen_positon: Vector2)
signal slot_drag_canceled(slot: Slot)

#adventure related
signal adventure_started
signal adventure_ended(victory: bool)
signal run_modifier_added()
signal run_modifier_removed()

#battle related
signal battle_won
signal battle_lost

#map related
signal room_entered(room: Room)
signal room_completed(room: Room)
signal map_exited(room: Room)

#Shop related
signal shop_entered
signal shop_exited

#Camp related
signal camp_entered
signal camp_exited
signal camp_party_rested
signal camp_looted
signal camp_trained
signal camp_enchanted
signal camp_smithed

#Battle reward related
signal battle_reward_exited

#teasure related
signal treasure_room_entered
signal treasure_room_exited

#Event node related
signal event_choice_made(choice: EventChoice)

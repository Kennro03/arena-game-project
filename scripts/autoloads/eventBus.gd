extends Node
class_name EventBus

@warning_ignore_start("unused_signal")

# UI related
## add item tooltips signal
## add weapon tooltips signal
## add unit tooltips signal
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
signal unit_recruited(unit: UnitData)
signal unit_lost(unit: UnitData)        # permadeath
signal unit_promoted(unit: UnitData)    # level threshold, class change, etc.
signal unit_moved_to_team(unit: UnitData)
signal unit_moved_to_reserve(unit: UnitData)

# Slot related
signal slot_hovered(slot: Slot)

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

#Battle reward related
signal battle_reward_exited

#teasure related
signal treasure_room_entered
signal treasure_room_exited

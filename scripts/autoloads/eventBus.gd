extends Node
class_name EventBus

@warning_ignore_start("unused_signal")

#economy related
signal gold_gained(value: int)
signal gold_lost(value: int)
signal gold_changed(new_total: int)

#item related
signal gain_item()
signal lose_item()
signal item_equipped()
signal item_unequipped()

# Unit related
signal unit_recruited(unit: UnitData)
signal unit_lost(unit: UnitData)        # permadeath
signal unit_promoted(unit: UnitData)    # level threshold, class change, etc.
signal unit_moved_to_team(unit: UnitData)
signal unit_moved_to_reserve(unit: UnitData)

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
signal shop_exited

#Camp related
signal camp_exited

#Battle reward related
signal battle_reward_exited

#teasure related
signal treasure_room_exited

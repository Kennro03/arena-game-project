extends Node
class_name Events

#adventure related
signal adventure_started
signal adventure_ended

#battle related
signal battle_won
signal battle_lost

#map related
signal map_exited(room: Room)

#Shop related
signal shop_existed

#Camp related
signal camp_exited

#Battle reward related
signal battle_reward_exited

#teasure related
signal treasure_room_exited

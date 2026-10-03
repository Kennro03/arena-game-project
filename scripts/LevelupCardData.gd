extends Resource
class_name LevelupCardData

enum CardRarityEnum {
	Normal, 
	Rare, 
	Special,
	Hybrid, 
	Debug,
}

enum CardType { ACTIVE_SKILL, PASSIVE_SKILL, STAT_BONUS, ITEM, UNIT }

@export var card_type: CardType 
@export var skill: Skill = null                               # for skill cards
@export var stat_buff: Buff = null                            # for stat bonus cards

@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var rarity: CardRarityEnum = CardRarityEnum.Normal    # for visual flair

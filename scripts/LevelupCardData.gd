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
#Maybe switch to a single 'resource' type ? and handle different operation cases here

@export var skill: Skill = null     # for active/passive skill cards
@export var stat_buff: Buff = null  # for stat bonus cards
#@export var item: Item = null  # for items, unused for now
#@export var unit: UnitData = null  # for units, unused for now

@export var display_name: String = ""
@export var description: String = ""
@export var tags: Array[String] = []
@export var icon: Texture2D = null
@export var rarity: CardRarityEnum = CardRarityEnum.Normal    # for visual flair

func get_tags() -> Array[String] : 
	match card_type :
		CardType.ACTIVE_SKILL : 
			return skill.tags
		CardType.PASSIVE_SKILL : 
			return skill.tags
		CardType.STAT_BONUS : 
			return ["Stat boost"]
	return []

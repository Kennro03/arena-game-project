extends HBoxContainer
@export var statname : String
@export var statPlaceholder : String

func _ready() -> void:
	setLabel(statname)
	setInputPlaceholder(statPlaceholder)
 
func setLabel(string) -> void :
	%Label.text = string

func setInputPlaceholder(string) -> void :
	%Input.text = string

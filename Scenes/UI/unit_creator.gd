extends Control

var statcontainerscene := load("res://Scenes/UI/stat_container.tscn")
var stickmanDictionnary : Dictionary


func _ready() -> void:
	getDictionnary.call_deferred()
	initialize_statcontainers.call_deferred()

func getDictionnary() -> void :
	stickmanDictionnary = StickmanData.new().get_stats_dictionnary()

func initialize_statcontainers() -> void :
	
	for key in stickmanDictionnary.keys() :
		if key != "color" and key != "team" and key != "skill_list":
			
			var statcontainer = statcontainerscene.instantiate()
			statcontainer.name = key + "_Container"
			statcontainer.statname = key
			statcontainer.statPlaceholder = str(stickmanDictionnary[key])
			$MarginContainer/VBoxContainer.add_child(statcontainer)
	
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/ColorSelectionContainer, $MarginContainer/VBoxContainer.get_child_count() - 1)
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/TeamSelectionContainer, $MarginContainer/VBoxContainer.get_child_count() - 1)
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/CreateButton, $MarginContainer/VBoxContainer.get_child_count() - 1)


func _on_create_button_pressed() -> void:
	var stickmandata := StickmanData.new()
	var stat_dict : Dictionary 
	
	for key in stickmanDictionnary.keys() :
		if key != "color" and key != "team" and key != "skill_list":
			stat_dict.set(key,$MarginContainer/VBoxContainer.get_node(key+"_Container").get_node("Input").text)
	
	stat_dict.set("color",$MarginContainer/VBoxContainer/ColorSelectionContainer/PopupPanel/VBoxContainer/ColorPicker.color)
	var team_options_button = $MarginContainer/VBoxContainer/TeamSelectionContainer/TeamOptions
	var selected_team : String = team_options_button.get_item_text(team_options_button.get_selected())
	if selected_team != "None" :
		var stickman_team = Team.registry.filter(func(t): return t.team_name == selected_team)[0]
		stat_dict.set("team",stickman_team)
	
	## Fix this >!!!<
	stickmandata = stickmandata.set_stats_using_dictionnary(stat_dict)
	print("Added stickman to inv : " + stickmandata.type)
	owner.inventory_module.add_unit(stickmandata)

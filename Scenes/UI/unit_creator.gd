extends Control

var statcontainerscene := load("res://Scenes/UI/stat_container.tscn")
var stickmanDictionnary : Dictionary

func _ready() -> void:
	getDictionnary.call_deferred()
	initialize_statcontainers.call_deferred()

func getDictionnary() -> void :
	stickmanDictionnary = Stickman.new().stats.get_stats_dictionary()

func initialize_statcontainers() -> void :
	var displaynamecontainer = statcontainerscene.instantiate()
	displaynamecontainer.name = "display_name_Container"
	displaynamecontainer.statname = "display_name"
	displaynamecontainer.statPlaceholder = "Stickman"
	$MarginContainer/VBoxContainer.add_child(displaynamecontainer)
	
	for key in stickmanDictionnary.keys() :
		if key != "skill_list":
			var statcontainer = statcontainerscene.instantiate()
			statcontainer.name = "base_"+ key + "_Container"
			statcontainer.statname = key
			statcontainer.statPlaceholder = str(stickmanDictionnary[key])
			$MarginContainer/VBoxContainer.add_child(statcontainer)
	
	
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/ColorSelectionContainer, $MarginContainer/VBoxContainer.get_child_count() - 1)
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/TeamSelectionContainer, $MarginContainer/VBoxContainer.get_child_count() - 1)
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/CreateButton, $MarginContainer/VBoxContainer.get_child_count() - 1)
	$MarginContainer/VBoxContainer.move_child($MarginContainer/VBoxContainer/WeaponSelectionContainer, 1)


func _on_create_button_pressed() -> void:
	var stickmandata := StickmanData.new()
	var stat_dict : Dictionary = {}
	
	for key in stickmanDictionnary.keys() :
		if key in ["color", "team", "skill_list"]:
			continue
		
		var line_input : String = $MarginContainer/VBoxContainer.get_node("base_%s_Container/Input" % key).text
		stat_dict[key] = float(line_input) 
	
	stickmandata.display_name = $MarginContainer/VBoxContainer.get_node("display_name_Container/Input").text
	
	var weapon_options_button = $MarginContainer/VBoxContainer/WeaponSelectionContainer/WeaponOptions
	var selected_weapon : Weapon = $MarginContainer/VBoxContainer/WeaponSelectionContainer.weapon_list[weapon_options_button.get_selected()]
	stickmandata.weapon = selected_weapon
	
	stat_dict.set("color",$MarginContainer/VBoxContainer/ColorSelectionContainer/PopupPanel/VBoxContainer/ColorPicker.color)
	
	var team_options_button = $MarginContainer/VBoxContainer/TeamSelectionContainer/TeamOptions
	var selected_team : String = team_options_button.get_item_text(team_options_button.get_selected())
	if selected_team != "None" :
		var stickman_team = Team.registry.filter(func(t): return t.team_name == selected_team)[0]
		stat_dict.set("team",stickman_team)
	
	
	stickmandata.stats.setup_base_stats_from_dict(stat_dict)
	print("Added stickman to inv : " + stickmandata.display_name)
	owner.inventory_module.add_unit(stickmandata)

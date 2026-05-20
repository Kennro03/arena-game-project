extends Node2D
class_name Event

@export var eventRessource : EventResource

@onready var ui: CanvasLayer = %UI
@onready var background: CanvasLayer = %Background
@onready var event_title_label: RichTextLabel = %EventTitle
@onready var event_image_texture_rect: TextureRect = %EventImage
@onready var event_description_label: RichTextLabel = %EventDescriptionLabel
@onready var choice_buttons_container: VBoxContainer = %ChoiceButtonsContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	if Player.pending_event != null :
		eventRessource = Player.pending_event
	elif eventRessource == null :
		print("No event provided, selecting random event...")
		var event_dir_address := "res://ressources/RandomEvents/EventList/"
		var event_dir := DirAccess.open(event_dir_address)
		var file_names := event_dir.get_files()
		var event_ressources_list : Array[EventResource] = []
		for file_name in file_names :
			if file_name.get_extension() == "tres":
				event_ressources_list.append(load(event_dir_address + file_name))
		eventRessource = event_ressources_list.pick_random()
	
	if eventRessource == null :
		printerr("No pending event or set event !")
		Player.return_to_previous_scene()
		return
	
	setup(eventRessource)
	Events.connect("event_choice_made",_on_choice_made)
	Player.ui_layer = ui

func setup(_event: EventResource) -> void:
	for c in %ChoiceButtonsContainer.get_children() :
		c.queue_free()
	
	event_title_label.text = _event.title
	event_description_label.text = _event.description
	
	if _event.image :
		event_image_texture_rect.texture = _event.image
		event_image_texture_rect.visible = true
	else : 
		event_image_texture_rect.visible = false
	
	for choice in _event.choices:
		var button := Button.new()
		button.text = choice.label
		button.add_theme_font_size_override("font_size",8)
		button.tooltip_text = choice.description
		#var requirements_met := choice.requirements.all(func(r): return r.is_met())
		#if not requirements_met:
			#if choice.is_locked_if_requirements_not_met:
				#button.disabled = true
				#button.tooltip_text = "Requirements not met"
			#else:
				#continue  # skip entirely
		
		button.pressed.connect(func():
			for effect in choice.effects:
				effect.apply()
			Events.event_choice_made.emit(choice)
			)
		choice_buttons_container.add_child(button)
	
	animation_player.play("reveal_event_animation")

func _on_choice_made(choice:EventChoice) -> void :
	
	if choice.new_event_on_selection :
		setup(choice.new_event_on_selection)
	elif choice.end_event_on_selection == true :
		Player.return_to_previous_scene()

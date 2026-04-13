extends Resource
class_name EventChoice

@export var label: String # choice line
@export_multiline var description: String  # shown on hover
#@export var requirements: Array[EventRequirement] = []  # conditions to show/enable
@export var effects: Array[EventEffect] = []  # what happens when chosen
@export var is_locked_if_requirements_not_met: bool = true  # show greyed out vs hide
@export var end_event_on_selection : bool = true
@export var new_event_on_selection : EventResource

extends Resource
class_name EventResource

@export var event_id: String
@export var title: String
@export_multiline var description: String
@export var image: Texture2D = null  # optional
@export var choices: Array[EventChoice] = []

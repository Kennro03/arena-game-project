extends Area2D
class_name MapRoom

signal selected(room: Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED : [preload("uid://b35ttgn7ku6ku"),Vector2.ONE],
	Room.Type.BATTLE : [preload("uid://c00hkg34w4sx6"),Vector2.ONE],
	Room.Type.SHOP : [preload("uid://c1vskmbmiurnh"),Vector2.ONE],
	Room.Type.TREASURE : [preload("uid://esx6uyb8exn"),Vector2.ONE],
	Room.Type.EVENT : [preload("uid://def75at2cg2fv"),Vector2.ONE],
	Room.Type.CAMP : [preload("uid://r4fnerxjbm5e"),Vector2.ONE],
	Room.Type.BOSS : [preload("uid://11r7yvtvtamh"),Vector2.ONE],
}

@onready var sprite_2d : Sprite2D = $Visuals/Sprite2D
@onready var line_2d : Line2D = $Visuals/Line2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var available := false : set = _set_available
var room : Room : set = set_room

func _set_available(new_value : bool)->void:
	available = new_value
	
	if available :
		animation_player.play("highlight")
		print("Highlighting room")
	elif not room.selected :
		animation_player.play("RESET")

func set_room(new_data: Room)-> void:
	room = new_data
	position = room.position
	line_2d.rotation = randi_range(0,360)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]

func show_selected() -> void :
	line_2d.modulate = Color.WHITE

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if not available or not _event.is_action_pressed("left_mouse"):
		return
	get_viewport().set_input_as_handled()
	room.selected = true
	animation_player.play("select")
	print("Selecting map room")
	_on_map_room_selected()

func _on_map_room_selected()->void:
	selected.emit(room)

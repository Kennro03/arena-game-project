extends Button
class_name Slot
@export var stickman_data: StickmanData = null
@export var tooltip_scene: PackedScene
var tooltip

signal stickman_selected(_stickman_data: Stickman)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_sprite()
	connect("pressed", Callable(self, "_on_pressed"))

func _process(_delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("stickman_selected", stickman_data)
	
	#if stickman_data :
		#print("Type : " + stickman_data.type)
		

func update_sprite() :
	if stickman_data :
		%StickmanSpriteIcon.texture = load("res://ressources/Sprites/Units/Stickman/Stickman White Tpose.png")
		%StickmanSpriteIcon.modulate = stickman_data.color
		%StickmanSpriteIcon.visible = true
	else : 
		%StickmanSpriteIcon.visible = false

func _on_mouse_entered():
	if stickman_data != null :
		tooltip = tooltip_scene.instantiate()
		get_tree().root.add_child(tooltip)
		tooltip.set_text("Display name : " + stickman_data.display_name)
		tooltip.add_line("Weapon : " + str(stickman_data.weapon.weaponName) + " (" + Weapon.WeaponTypeEnum.keys()[stickman_data.weapon.weaponType] + ")")
		tooltip.add_line("STR = " + str(stickman_data.stats.current_strength))
		tooltip.add_line("END = " + str(stickman_data.stats.current_endurance))
		tooltip.add_line("DEX = " + str(stickman_data.stats.current_dexterity))
		tooltip.add_line("INT = " + str(stickman_data.stats.current_intellect))
		tooltip.add_line("FAI = " + str(stickman_data.stats.current_faith))
		tooltip.add_line("ATT = " + str(stickman_data.stats.current_attunement))
		

func _on_mouse_exited():
	if tooltip :
		tooltip.queue_free()

extends Control
@export var inventory_module : Node 


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == true :
			get_tree().paused = false
			$PauseLabel.hide()
		else :
			get_tree().paused = true
			$PauseLabel.show()


func _on_inventory_button_toggled(toggled_on: bool) -> void:
	if toggled_on and $UnitCreator.visible == false : 
		$"Inventory module/Inventory".show()
	else :
		$"Inventory module/Inventory".hide()


func _on_unit_creator_button_toggled(toggled_on: bool) -> void:
	if toggled_on and $"Inventory module/Inventory".visible == false : 
		$UnitCreator.show()
	else :
		$UnitCreator.hide()

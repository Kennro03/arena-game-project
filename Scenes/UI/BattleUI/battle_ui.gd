extends Control

signal StartEncounterPressed()
signal introEnded

const UnitInfoPanelScene := preload("res://Scenes/UI/UnitInfoPanel/unit_info_panel.tscn")

@export var selection_manager: SelectionManager
@export var ui_root: CanvasLayer

var unit_info_panel: Control = null

@onready var animationPlayer := $AnimationPlayer

func _ready() -> void:
	selection_manager.unit_selected.connect(_on_unit_selected)
	selection_manager.unit_deselected.connect(_on_unit_deselected)
	Events.open_unit_info_requested.connect(_spawn_unit_info_panel)
	#Events.open_item_info_requested.connect(_spawn_item_info_panel)

func _on_start_fight_button_pressed() -> void:
	StartEncounterPressed.emit()

func _on_begin_encounter() -> void:
	animationPlayer.play("hide_start_fight_button")
	await animationPlayer.animation_finished
	introEnded.emit()


func _on_unit_selected(unit: BaseUnit) -> void:
	if Input.is_action_pressed("DisplayUnitInfo"):
		_spawn_unit_info_panel(unit)

func _on_unit_deselected() -> void:
	pass

func _spawn_unit_info_panel(unit: BaseUnit) -> void:
	#if is_instance_valid(unit_info_panel):
		#unit_info_panel.queue_free()
	unit_info_panel = UnitInfoPanelScene.instantiate()
	unit_info_panel.unit = unit
	unit_info_panel.name = unit.id + "_InfoPanel"
	ui_root.add_child(unit_info_panel)

func _on_lost_encounter() -> void:
	animationPlayer.play("LostAnimation")

func _on_won_encounter() -> void:
	animationPlayer.play("WinAnimation")

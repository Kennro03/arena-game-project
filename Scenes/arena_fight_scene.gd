extends Node2D
class_name ArenaFightScene

signal fight_ended(winning_team: Team, all_teams: Array[Team], is_draw: bool)

enum FightState { SETUP, SPAWNING, COUNTDOWN, FIGHTING, RESOLVING, DONE }

const TEAM_COLORS: Array[Color] = [
	Color(0.9, 0.2, 0.2),  
	Color(0.2, 0.4, 0.9),  
	Color(0.2, 0.8, 0.2),  
	Color(0.9, 0.8, 0.1),   
	Color(0.8, 0.2, 0.9),   
	Color(0.9, 0.5, 0.1),   
	Color(0.1, 0.8, 0.8),   
	Color(0.9, 0.3, 0.6),   
]

# ── Config ──────────────────────────────────────────────────────────────
@export_group("Testing")
@export var test_mode: bool = false
@export var test_teams: Array[ArenaTestTeam] = []

# fallback generation if test_teams is empty
@export var test_auto_generate: bool = true
@export var test_fighter_count_per_team: int = 2
@export var test_team_count: int = 2
@export var test_starting_exp: int = 0

@export_group("Fight settings")
@export var fight_config: ArenaFightConfig = ArenaFightConfig.new()

# ── Nodes ───────────────────────────────────────────────────────────────
@onready var ui_layer: CanvasLayer = %UILayer
@onready var overlay_layer: CanvasLayer = %OverlayLayer
@onready var units_layer: Node2D = %Units
@onready var arena: Node2D = %Arena   # the circle, purely visual
@onready var countdown_label: Label = %CountdownLabel
@onready var status_label: Label = %StatusLabel
@onready var speed_spin_box: SpinBox = %SpeedSpinBox
@onready var speed_slider: HSlider = %SpeedSlider
@onready var pause_button: Button = %PauseButton
@onready var menu_button: Button = %MenuButton
@onready var menu_panel: Control = %MenuPanel       # slides in from side
@onready var selection_manager: SelectionManager = %SelectionManager

# ── State ────────────────────────────────────────────────────────────────
var _teams: Array[Team] = []
var _team_fighters: Dictionary = {}      # Team -> Array[FighterData]
var _team_spawn_points: Dictionary = {}  # Team -> Vector2
var _team_units_alive: Dictionary = {}   # Team -> Array[Unit]
var _state: FightState = FightState.SETUP
var _paused: bool = false

var _caller: Node = null   # ArenaCircuit or TournamentCircuit — null if test mode

# called by ArenaCircuit/TournamentCircuit before adding to scene tree
func setup(teams: Array[Team], team_fighters: Dictionary, config: ArenaFightConfig, caller: Node) -> void:
	test_mode = false
	_teams = teams
	_team_fighters = team_fighters  # Team -> Array[FighterData]
	for team in teams:
		_team_units_alive[team] = []
	fight_config = config
	_caller = caller

func _ready() -> void:
	Player.ui_layer = ui_layer
	Player.overlay_layer = overlay_layer
	
	# wire UI
	pause_button.pressed.connect(_toggle_pause)
	menu_button.pressed.connect(_toggle_menu)
	speed_slider.value_changed.connect(func(v): Engine.time_scale = v)
	speed_slider.value = fight_config.simulation_speed
	speed_slider.value_changed.connect(speed_spin_box.set_value_no_signal)
	speed_spin_box.value_changed.connect(func(v): Engine.time_scale = v)
	speed_spin_box.value = fight_config.simulation_speed
	speed_spin_box.value_changed.connect(speed_slider.set_value_no_signal)
	menu_panel.visible = false
	countdown_label.visible = false
	status_label.visible = false
	
	if test_mode:
		_build_test_teams()
	
	_compute_spawn_points()
	_begin_spawn_sequence()

# ── Team setup ────────────────────────────────────────────────────────────

func _build_test_teams() -> void:
	_teams.clear()
	
	if not test_teams.is_empty():
		# use custom defined teams
		for i in test_teams.size():
			var test_team := test_teams[i]
			var color : Color = test_team.override_color \
				if test_team.override_color != Color.TRANSPARENT \
				else TEAM_COLORS[i % TEAM_COLORS.size()]
			var team := Team.create(test_team.team_name, color)
			_teams.append(team)
			_team_fighters[team] = []
			_team_units_alive[team] = []
			
			for unit_data in test_team.fighters:
				if unit_data == null:
					continue
				var fighter := FighterData.new()
				fighter.arena_id = "test_%d_%s" % [i, unit_data.display_name]
				fighter.unit_data = unit_data.duplicate(true)
				_team_fighters[team].append(fighter)
	
	elif test_auto_generate:
		# fallback: generate random fighters
		for i in test_team_count:
			var team := Team.create(
				"Team %d" % (i + 1),
				TEAM_COLORS[i % TEAM_COLORS.size()])
			_teams.append(team)
			_team_fighters[team] = []
			_team_units_alive[team] = []
			
			for j in test_fighter_count_per_team:
				var fighter := FighterData.new()
				fighter.arena_id = "test_%d_%d" % [i, j]
				var data := UnitData.new()
				data.display_name = "%s Fighter %d" % [team.team_name, j + 1]
				data.stats.experience = test_starting_exp
				if fighter.stat_archetype:
					data.spend_points_with_archetype(fighter.stat_archetype)
				else:
					data.auto_spend_attribute_points()
				fighter.unit_data = data
				_team_fighters[team].append(fighter)
	else:
		printerr("ArenaFightScene: test_mode is on but no teams defined and auto_generate is off")

# ── Spawn point calculation ───────────────────────────────────────────────

func _compute_spawn_points() -> void:
	# distribute teams evenly around the arena circle
	var team_count := _teams.size()
	print("Team count = " + str(team_count))
	for i in team_count:
		var angle : float = (TAU / team_count) * i  # start from right
		var point : Vector2 = Vector2(
			cos(angle) * fight_config.arena_radius * 0.6,
			sin(angle) * fight_config.arena_radius * 0.6)
		_team_spawn_points[_teams[i]] = point
	
	#if arena and arena.has_method("set_radius"):
	#	arena.set_radius(fight_config.arena_radius)

# ── Spawn sequence ────────────────────────────────────────────────────────

func _begin_spawn_sequence() -> void:
	_state = FightState.SPAWNING
	status_label.visible = true
	status_label.text = "Deploying fighters..."
	_spawn_all_units()

func _spawn_all_units() -> void:
	var delay := 0.0
	for team in _teams:
		for fighter in _team_fighters[team]:
			get_tree().create_timer(delay).timeout.connect(
				func(): _spawn_unit(fighter, team))
			delay += fight_config.spawn_delay_between_units
	get_tree().create_timer(delay + 0.5).timeout.connect(_begin_countdown)

func _spawn_unit(fighter: FighterData, team: Team) -> void:
	if not is_instance_valid(fighter.unit_data):
		return
	
	var data := fighter.unit_data._make_copy()
	data.team = team
	#Don't change the unit's color to the team's
	#data.color = team.team_color
	
	var unit := _spawn_from_data(_team_spawn_points[team], data)
	if unit == null:
		return
	
	unit.active = false
	_team_units_alive[team].append(unit)
	unit.unit_downed.connect(func(_dying_unit, _killer): _on_unit_downed(unit, team))
	selection_manager.register_unit(unit)

func _spawn_from_data(center: Vector2, data: UnitData) -> Unit:
	if data == null or data.unit_scene == null:
		printerr("ArenaFightScene: invalid UnitData for spawning")
		return null
	
	# scatter around center point
	var angle := randf() * TAU
	var dist := randf() * fight_config.spawn_radius
	var pos := center + Vector2(cos(angle), sin(angle)) * dist
	
	var unit := data.unit_scene.instantiate()
	unit.position = pos
	unit.unit_data = data
	unit.active = false
	unit.apply_data(data._make_copy())
	units_layer.add_child(unit)
	return unit

# ── Countdown ─────────────────────────────────────────────────────────────

func _begin_countdown() -> void:
	_state = FightState.COUNTDOWN
	status_label.visible = false
	countdown_label.visible = true
	_tick_countdown(3)

func _tick_countdown(count: int) -> void:
	if count <= 0:
		countdown_label.visible = false
		_start_fight()
		return
	countdown_label.text = str(count)
	print("Countdown: %d" % count)
	get_tree().create_timer(1.0).timeout.connect(func(): _tick_countdown(count - 1))

func _start_fight() -> void:
	_state = FightState.FIGHTING
	Events.combat_started.emit()
	print("Fight start!")
	for team in _teams:
		for unit in _team_units_alive[team]:
			if is_instance_valid(unit):
				unit.active = true

# ── Victory detection ─────────────────────────────────────────────────────

func _on_unit_downed(unit: Unit, team: Team) -> void:
	# will need to check for ressurections here before removing from teams later
	if not is_instance_valid(unit) or unit.is_downed:
		_team_units_alive[team].erase(unit)
		_check_victory()

func _check_victory() -> void:
	if _state != FightState.FIGHTING:
		return
	
	# filter out empty teams
	var surviving_teams := _teams.filter(func(t): 
		return not _team_units_alive[t].filter(func(u): 
			return is_instance_valid(u) and not u.is_downed).is_empty())
	
	if surviving_teams.size() == 1:
		_end_fight(surviving_teams[0], false)
	elif surviving_teams.is_empty():
		_end_fight(null, true)  # draw — everyone down simultaneously

func _end_fight(winning_team: Team, is_draw: bool) -> void:
	if _state == FightState.RESOLVING or _state == FightState.DONE:
		return
	_state = FightState.RESOLVING
	
	# disable all fighters
	for team in _teams:
		for unit in _team_units_alive[team]:
			if is_instance_valid(unit):
				unit.active = false
	
	# display result
	status_label.visible = true
	if is_draw:
		status_label.text = "Draw!"
		print("Fight ended: Draw")
	else:
		status_label.text = "%s wins!" % winning_team.team_name
		print("Fight ended: %s wins!" % winning_team.team_name)
	
	Engine.time_scale = 1.0  # reset speed
	
	Events.combat_ended.emit()
	
	# wait then return
	get_tree().create_timer(fight_config.post_fight_delay).timeout.connect(func():
		_state = FightState.DONE
		fight_ended.emit(winning_team, _teams, is_draw)
		if _caller != null:
			_return_to_caller(winning_team, is_draw))
		# else: test mode, stay in scene for inspection

func _return_to_caller(winning_team: Team, is_draw: bool) -> void:
	if _caller.has_method("on_fight_result"):
		_caller.on_fight_result(winning_team, _teams, is_draw)
	queue_free()

# ── UI handlers ───────────────────────────────────────────────────────────

func _toggle_pause() -> void:
	_paused = not _paused
	Engine.time_scale = 0.0 if _paused else speed_slider.value
	pause_button.text = "Resume" if _paused else "Pause"

func _toggle_menu() -> void:
	menu_panel.visible = not menu_panel.visible

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_menu()

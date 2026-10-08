extends Control
class_name ArenaCircuit

const PARTICIPANT_SLOT = preload("res://Scenes/participant_slot.tscn")
const ARENA_FIGHT_SCENE = preload("res://Scenes/arena_fight_scene.tscn")

@export var auto_proceed: bool = true
@export var auto_proceed_delay: float = 3.0      # seconds before next match starts
@export var highlight_duration: float = 2.0      # seconds fighters are highlighted before transition

@onready var slots_container: GridContainer = %SlotsContainer
@onready var standings_container: VBoxContainer = %StandingsContainer
@onready var matchup_label: RichTextLabel = %MatchupLabel
@onready var next_match_button: Button = %NextMatchButton
@onready var auto_proceed_check: CheckBox = %AutoProceedCheck
@onready var countdown_label: Label = %CountdownLabel
@onready var status_label: Label = %StatusLabel

var _fighters: Array[FighterData] = []
var _config: ArenaConfig = null
var _slots: Array[ParticipantSlot] = []
var _current_matchup: Array[FighterData] = []
var _auto_timer: float = 0.0
var _is_counting_down: bool = false
var _highlighted_slots: Array[ParticipantSlot] = []
var _current_team_fighters: Dictionary = {}  

# round tracking
var _current_round: int = 0
var _fights_this_round: int = 0
var _round_robin_completed_pairs: Array = []  # Array of [FighterData, FighterData]
var _gauntlet_fought_this_round: Array[FighterData] = []

func setup(fighters: Array[FighterData], config: ArenaConfig) -> void:
	_fighters = fighters
	_config = config
	auto_proceed = config.pause_between_rounds == false

func _ready() -> void:
	_fighters = Player.pending_arena_fighters
	_config = Player.pending_arena_config
	Player.pending_arena_fighters = []
	Player.pending_arena_config = null
	
	next_match_button.pressed.connect(_proceed_to_match)
	auto_proceed_check.button_pressed = auto_proceed
	auto_proceed_check.toggled.connect(func(v): auto_proceed = v)
	_build_slots()
	_refresh_standings()
	_select_next_matchup()

func _build_slots() -> void:
	for old_slot in slots_container.get_children() :
		old_slot.queue_free()
	
	for fighter in _fighters:
		print("Set fighter")
		var slot := PARTICIPANT_SLOT.instantiate() as ParticipantSlot
		slots_container.add_child(slot)
		slot.set_fighter(fighter)
		slot.remove_requested.connect(func(): pass)  # disabled in circuit
		_slots.append(slot)

func _select_next_matchup() -> void:
	_clear_highlights()
	var pair := _pick_matchup()
	if pair.is_empty():
		_on_no_matchup_available()
		return
	
	_current_matchup = pair
	_highlight_fighters(pair)
	_update_matchup_label(pair)
	
	if auto_proceed:
		_is_counting_down = true
		_auto_timer = highlight_duration
	else:
		next_match_button.visible = true
		next_match_button.disabled = false
		countdown_label.visible = false

func _pick_matchup() -> Array[FighterData]:
	match _config.round_format if _config else ArenaConfig.RoundFormat.CONTINUOUS:
		ArenaConfig.RoundFormat.GAUNTLET:
			return _pick_gauntlet_matchup()
		ArenaConfig.RoundFormat.ROUND_ROBIN:
			return _pick_round_robin_matchup()
		_:
			return _pick_continuous_matchup()  # existing logic renamed

func _on_no_matchup_available() -> void:
	status_label.text = "No valid matchup available."
	next_match_button.visible = false
	matchup_label.text = ""



func _highlight_fighters(pair: Array[FighterData]) -> void:
	for slot in _slots:
		if slot.get_fighter() in pair:
			slot.set_highlighted(true)
			_highlighted_slots.append(slot)
		else:
			slot.modulate.a = 0.4  # dim others

func _clear_highlights() -> void:
	for slot in _slots:
		slot.modulate.a = 1.0
		slot.set_highlighted(false)
	_highlighted_slots.clear()

func _update_matchup_label(pair: Array[FighterData]) -> void:
	matchup_label.clear()
	matchup_label.append_text("[center]%s  vs  %s[/center]" % [
		pair[0].unit_data.display_name,
		pair[1].unit_data.display_name])

func _process(delta: float) -> void:
	if not _is_counting_down:
		return
	_auto_timer -= delta
	countdown_label.visible = true
	countdown_label.text = "Starting in %.1f..." % max(_auto_timer, 0.0)
	if _auto_timer <= 0.0:
		_is_counting_down = false
		countdown_label.visible = false
		_proceed_to_match()

func _proceed_to_match() -> void:
	if _current_matchup.size() < 2:
		return
	next_match_button.visible = false
	_is_counting_down = false
	_transition_to_fight(_current_matchup)  

func _transition_to_fight(matchup: Array[FighterData]) -> void:
	_current_team_fighters.clear()
	var teams: Array[Team] = []
	var team_fighters: Dictionary = {}
	
	for i in matchup.size():
		var fighter := matchup[i]
		var team := Team.create(
			"Team %d" % (i + 1),
			ArenaFightScene.TEAM_COLORS[i % ArenaFightScene.TEAM_COLORS.size()])
		teams.append(team)
		team_fighters[team] = [fighter]          # 1v1: one fighter per team
		_current_team_fighters[team] = [fighter] # store for result mapping
	
	var config := ArenaFightConfig.new()
	config.simulation_speed = _config.simulation_speed if _config else 1.0
	
	var scene := ARENA_FIGHT_SCENE.instantiate() as ArenaFightScene
	scene.setup(teams, team_fighters, config, self)
	get_tree().root.add_child(scene)
	hide()

func _simulate_fight(matchup: Array[FighterData]) -> void:
	var winner_index := randi() % matchup.size()
	var winner := matchup[winner_index]
	var losers := matchup.filter(func(f): return f != winner)
	_on_fight_result_multi(winner, losers, false)

func _apply_progression(fighters: Array[FighterData]) -> void:
	for f in fighters:
		if f.fights_count % _config.progression_every_x_fight == 0:
			if _config.exp_gained_per_prog > 0:
				f.unit_data.stats.experience += _config.exp_gained_per_prog
			if _config.level_gained_per_prog > 0:
				var target_level := f.unit_data.stats.level + _config.level_gained_per_prog
				f.unit_data.stats.experience = f.unit_data.stats.get_xp_for_level(target_level)

func _check_round_end(all_involved: Array[FighterData]) -> void:
	match _config.round_format:
		ArenaConfig.RoundFormat.GAUNTLET:
			for f in all_involved:
				_gauntlet_fought_this_round.append(f)
			var unfought := _fighters.filter(func(f): 
				return f not in _gauntlet_fought_this_round)
			if unfought.size() <= 1:  # round complete (1 = bye)
				_current_round += 1
				_gauntlet_fought_this_round.clear()
		ArenaConfig.RoundFormat.ROUND_ROBIN:
			_round_robin_completed_pairs.append(all_involved)
		ArenaConfig.RoundFormat.CONTINUOUS:
			pass  # no round concept

func _pick_gauntlet_matchup() -> Array[FighterData]:
	var available := _fighters.filter(func(f): 
		return f not in _gauntlet_fought_this_round)
	if available.size() < 2:
		return []  # round over — _check_round_end handles reset
	available.shuffle()
	return [available[0], available[1]]

func _pick_round_robin_matchup() -> Array[FighterData]:
	for i in _fighters.size():
		for j in range(i + 1, _fighters.size()):
			var pair := [_fighters[i], _fighters[j]]
			var already_fought := _round_robin_completed_pairs.any(func(p):
				return (p[0] == pair[0] and p[1] == pair[1]) or (p[0] == pair[1] and p[1] == pair[0]))
			if not already_fought:
				return pair
	# all pairs exhausted — round robin complete
	_round_robin_completed_pairs.clear()
	_current_round += 1
	return _pick_round_robin_matchup()  # start new round

func _pick_continuous_matchup() -> Array[FighterData]:
	# existing _pick_matchup logic
	if _fighters.size() < 2:
		return []
	var min_fights: int = _fighters.map(func(f): return f.fights_count).min()
	var least_fought := _fighters.filter(func(f): return f.fights_count == min_fights)
	if least_fought.size() >= 2:
		least_fought.shuffle()
		return [least_fought[0], least_fought[1]]
	var first: FighterData = least_fought[0]
	var others := _fighters.filter(func(f): return f != first)
	if others.is_empty():
		return []
	others.shuffle()
	return [first, others[0]]

func on_fight_result(winning_team: Team, all_teams: Array[Team], is_draw: bool) -> void:
	show()
	if is_draw:
		var all_fighters: Array[FighterData] = []
		for team in all_teams:
			var team_fighters: Array = _current_team_fighters.get(team, [])
			for f in team_fighters:
				all_fighters.append(f)
		_on_fight_result_multi(null, all_fighters, true)
		return
	
	var winner_array: Array = _current_team_fighters.get(winning_team, [])
	var winners: Array[FighterData] = []
	for f in winner_array:
		winners.append(f)
	
	var losers: Array[FighterData] = []
	for team in all_teams:
		if team != winning_team:
			var team_fighters: Array = _current_team_fighters.get(team, [])
			for f in team_fighters:
				losers.append(f)
	
	_on_fight_result_multi(winners[0] if not winners.is_empty() else null, losers, false)

func _on_fight_result_multi(winner: FighterData, losers: Array[FighterData], is_draw: bool) -> void:
	var all_involved: Array[FighterData] = []
	if winner:
		all_involved.append(winner)
	all_involved.append_array(losers)
	
	# record results
	if is_draw:
		for f in all_involved:
			f.draws += 1
			f.fights_count += 1
	else:
		if winner:
			winner.wins += 1
			winner.fights_count += 1
		for f in losers:
			f.losses += 1
			f.fights_count += 1
	
	# apply progression
	_apply_progression(all_involved)
	
	# gear reroll
	if _config and _config.gear_handling == ArenaConfig.GearHandling.REROLL_AFTER_FIGHT:
		for f in all_involved:
			_reroll_gear(f)
	
	_check_round_end(all_involved)
	_refresh_standings()
	_refresh_slot_tooltips()
	
	if auto_proceed:
		await get_tree().create_timer(auto_proceed_delay).timeout
	_select_next_matchup()

func _reroll_gear(fighter: FighterData) -> void:
	if fighter.unit_data == null:
		return
	var config := FighterGenerationConfig.new()
	config.allowed_weapon_types = _config.reroll_allowed_weapon_types
	config.allowed_weapon_materials = _config.reroll_allowed_weapon_materials
	config.starting_exp = fighter.unit_data.stats.experience
	# generate a new weapon from allowed pool
	var weapon := _generate_weapon_for_fighter(fighter, config)
	if weapon:
		fighter.unit_data.weapon = weapon

func _generate_weapon_for_fighter(fighter: FighterData, config: FighterGenerationConfig) -> Weapon:
	var allowed_types := config.allowed_weapon_types
	if allowed_types.is_empty():
		return null
	var type : Weapon.WeaponTypeEnum = allowed_types.pick_random()
	var mat: ItemMaterial = null
	if not config.allowed_weapon_materials.is_empty():
		mat = config.allowed_weapon_materials.pick_random()
	var base_weapons := MaterialRegistry.get_all_materials()  # placeholder — load from weapon pool
	# weapon generation logic depends on how your weapon pool is structured
	return null  # fill in when weapon pool is accessible



func _refresh_standings() -> void:
	for c in standings_container.get_children():
		c.queue_free()
	
	var sorted := _fighters.duplicate()
	sorted.sort_custom(func(a, b): 
		if a.wins != b.wins: return a.wins > b.wins
		return a.losses < b.losses)
	
	for i in sorted.size():
		var fighter : FighterData = sorted[i]
		var row := HBoxContainer.new()
		var rank_label := Label.new()
		rank_label.text = "%d." % (i + 1)
		rank_label.custom_minimum_size.x = 24
		var name_label := Label.new()
		name_label.text = fighter.unit_data.display_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var record_label := Label.new()
		record_label.text = "%dW / %dL / %dD" % [fighter.wins, fighter.losses, fighter.draws]
		row.add_child(rank_label)
		row.add_child(name_label)
		row.add_child(record_label)
		standings_container.add_child(row)

func _refresh_slot_tooltips() -> void:
	for slot in _slots:
		slot.set_fighter(slot.get_fighter())  # triggers tooltip refresh

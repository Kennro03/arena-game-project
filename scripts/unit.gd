extends Node2D
class_name Unit

@warning_ignore_start("unused_signal")
signal hit_received(hit_data: HitData)
signal unit_clicked(unit: Unit)
signal unit_died(unit: Unit, killer: Unit)
signal unit_downed(unit: Unit, killer: Unit)
signal weapon_changed(weapon: Weapon)
signal accessories_changed(accessories: Array[Accessory])


# return unit_data values
var id: String:
	get: return unit_data.id if unit_data else ""
var unit_name: String:
	get: return unit_data.display_name if unit_data else ""
var unit_type: String:
	get: return unit_data.unit_type if unit_data else ""
var description: String:
	get: return unit_data.description if unit_data else ""
var icon: Texture2D:
	get: return unit_data.icon if unit_data else null
var color: Color:
	get: return unit_data.color if unit_data else Color.WHITE
var show_name: bool:
	get: return unit_data.show_name if unit_data else true
var show_health: bool:
	get: return unit_data.show_health if unit_data else true

# Core
var team: Team = null
var stats: Stats = Stats.new()
var skill_list: Array[Skill] = []
var weapon: Weapon = null
var default_weapon: Weapon = null
var accessories: Array[Accessory] = []

# Runtime identity
var unit_data: UnitData = null
var summoner: Unit = null
var last_hit_owner: Unit = null

var active: bool = true:
	set(value):
		active = value
		if active: _on_activated.call_deferred()
		else: _on_deactivated.call_deferred()

func _ready() -> void:
	add_to_group("Live_Units")

# --- Team logic (universal, summoner chain works for all unit types) ---
func get_effective_team() -> Team:
	if summoner != null: return summoner.get_effective_team()
	return team

func get_summoner_root() -> Unit:
	if summoner == null: return self
	return summoner.get_summoner_root()

func check_if_ally(target: Node2D) -> bool:
	if not is_instance_valid(target): return false
	var my_root := get_summoner_root()
	var their_root: Unit = target.get_summoner_root() if target.has_method("get_summoner_root") else target
	if my_root == their_root and my_root != null: return true
	var my_team := get_effective_team()
	var their_team: Team = target.get_effective_team() if target.has_method("get_effective_team") else target.team
	if not is_instance_valid(my_team) or not is_instance_valid(their_team): return false
	return my_team.team_name == their_team.team_name

# --- Combat interface (virtual, subclasses implement) ---
func take_damage(_damage: float, _type: HitData.DamageType = HitData.DamageType.NONE, _owner: Unit = null) -> void:
	pass

func resolve_hit(_hit: HitData) -> void:
	pass

func get_downed() -> void:
	unit_downed.emit(self, last_hit_owner)

func die() -> void:
	unit_died.emit(self, last_hit_owner)
	queue_free()

func apply_stun(_duration: float) -> void:
	pass  # unit specific overrides

func apply_data(data: UnitData) -> void:
	color = data.color
	unit_data = data
	team = data.team
	stats = data.stats
	stats.setup_stats()

# --- Hooks ---
func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass

# --- Statics --- 
static func apply_buff(buff: Buff, unit: Unit) -> void:
	if unit == null: return
	match buff.domain:
		Buff.Domain.UNIT: unit.stats.add_buff(buff)
		Buff.Domain.WEAPON: if unit.weapon: unit.weapon.add_weapon_buff(buff)

static func remove_buff(buff: Buff, unit: Unit) -> void:
	if unit == null: return
	match buff.domain:
		Buff.Domain.UNIT: unit.stats.remove_buff(buff)
		Buff.Domain.WEAPON: if unit.weapon: unit.weapon.remove_weapon_buff(buff)

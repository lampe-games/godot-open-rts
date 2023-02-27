extends Node

signal resources_required(resources, metadata)

const Worker = preload("res://source/match/units/Worker.gd")
const CommandCenter = preload("res://source/match/units/CommandCenter.gd")
const VehicleFactory = preload("res://source/match/units/VehicleFactory.gd")
const VehicleFactoryScene = preload("res://source/match/units/VehicleFactory.tscn")
const Tank = preload("res://source/match/units/Tank.gd")
const TankScene = preload("res://source/match/units/Tank.tscn")
const AircraftFactory = preload("res://source/match/units/AircraftFactory.gd")
const AircraftFactoryScene = preload("res://source/match/units/AircraftFactory.tscn")
const Helicopter = preload("res://source/match/units/Helicopter.gd")
const HelicopterScene = preload("res://source/match/units/Helicopter.tscn")
const AutoAttackingBattlegroup = preload(
	"res://source/match/players/simple-clairvoyant-ai/AutoAttackingBattlegroup.gd"
)

const REFRESH_INTERVAL = 1.0 / 60.0 * 30.0

var _player = null
var _primary_structure_scene = null
var _secondary_structure_scene = null
var _number_of_pending_structure_resource_requests = {}
var _primary_unit_scene = null
var _secondary_unit_scene = null
var _number_of_pending_unit_resource_requests = {}
var _battlegroup_under_forming = null
var _battlegroups = []

@onready var _ai = get_parent()


func setup(player):
	_player = player
	_primary_structure_scene = (
		VehicleFactoryScene
		if _ai.primary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
		else AircraftFactoryScene
	)
	_secondary_structure_scene = (
		VehicleFactoryScene
		if _ai.secondary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
		else AircraftFactoryScene
	)
	_primary_unit_scene = (
		TankScene
		if _ai.primary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
		else HelicopterScene
	)
	_secondary_unit_scene = (
		TankScene
		if _ai.secondary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
		else HelicopterScene
	)
	_setup_refresh_timer()
	_try_creating_new_battlegroup()
	# TODO: attach structures
	# TODO: attach units (form battlegroups)
	MatchSignals.unit_spawned.connect(_on_unit_spawned)
	_enforce_primary_structure_existence()


func provision(resources, metadata):
	if metadata == "primary_structure":
		_provision_structure(_primary_structure_scene, resources, metadata)
	elif metadata == "secondary_structure":
		_provision_structure(_secondary_structure_scene, resources, metadata)
	elif metadata == "primary_unit":
		_provision_unit(_primary_unit_scene, _primary_structure(), resources, metadata)
	elif metadata == "secondary_unit":
		_provision_unit(_secondary_unit_scene, _secondary_structure(), resources, metadata)
	else:
		assert(false)  # unexpected flow


func _setup_refresh_timer():
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_refresh_timer_timeout)
	timer.start(REFRESH_INTERVAL)


func _provision_structure(structure_scene, resources, metadata):
	assert(resources == Constants.Match.Units.CONSTRUCTION_COSTS[structure_scene.resource_path])
	var workers = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Worker and unit.player == _player
	)
	_number_of_pending_structure_resource_requests[metadata] -= 1
	if workers.is_empty():
		return
	_construct_structure(structure_scene)


func _provision_unit(unit_scene, structure_producing_unit, resources, metadata):
	assert(resources == Constants.Match.Units.PRODUCTION_COSTS[unit_scene.resource_path])
	if structure_producing_unit == null:
		return
	_number_of_pending_unit_resource_requests[metadata] -= 1
	structure_producing_unit.action.produce(unit_scene)


func _try_creating_new_battlegroup():
	if not _battlegroups.is_empty():
		_enforce_secondary_structure_existence()
	if _battlegroups.size() == _ai.expected_number_of_battlegroups:
		var primary_structure = _primary_structure()
		if primary_structure != null:
			primary_structure.action.cancel_all()
		_battlegroup_under_forming = null
		return false
	var adversary_players = find_parent("Match").players.filter(
		func(player): return player != _player
	)
	adversary_players.shuffle()
	var battlegroup = AutoAttackingBattlegroup.new(
		_ai.expected_number_of_units_in_battlegroup, adversary_players
	)
	_battlegroups.append(battlegroup)
	battlegroup.tree_exited.connect(_on_battlegroup_died.bind(battlegroup))
	add_child(battlegroup)
	_battlegroup_under_forming = battlegroup
	return true


func _construct_structure(structure_scene):
	var construction_cost = Constants.Match.Units.CONSTRUCTION_COSTS[structure_scene.resource_path]
	assert(_player.has_resources(construction_cost))
	# TODO: introduce actual algorithm which takes enemy positions into account
	var ccs = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is CommandCenter and unit.player == _player
	)
	var workers = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Worker and unit.player == _player
	)
	var reference_position_for_placement = (
		ccs[0].global_position if not ccs.is_empty() else workers[0].global_position
	)
	var placement_position = Utils.Match.BuildingPlacement.find_valid_position_radially(
		reference_position_for_placement, 2, get_tree()
	)  # TODO: get radius from somewhere - constants(?)
	var target_transform = Transform3D(Basis(), placement_position).looking_at(
		placement_position + Vector3(-1, 0, 1), Vector3.UP
	)
	_player.subtract_resources(construction_cost)
	MatchSignals.setup_and_spawn_unit.emit(structure_scene.instantiate(), target_transform, _player)
	_enforce_primary_units_production.call_deferred()


func _enforce_primary_structure_existence():
	_enforce_structure_existence(
		_primary_structure(), _primary_structure_scene, "primary_structure"
	)


func _enforce_secondary_structure_existence():
	_enforce_structure_existence(
		_secondary_structure(), _secondary_structure_scene, "secondary_structure"
	)


func _enforce_structure_existence(structure, structure_scene, type):
	if structure == null and _number_of_pending_structure_resource_requests.get(type, 0) == 0:
		resources_required.emit(
			Constants.Match.Units.CONSTRUCTION_COSTS[structure_scene.resource_path], type
		)
		_number_of_pending_structure_resource_requests[type] = (
			_number_of_pending_structure_resource_requests.get(type, 0) + 1
		)


func _enforce_primary_units_production():
	_enforce_units_production(_primary_structure(), _primary_unit_scene, "primary_unit")


func _enforce_secondary_units_production():
	_enforce_units_production(_secondary_structure(), _secondary_unit_scene, "secondary_unit")


func _enforce_units_production(structure, unit_scene, type):
	if structure == null or not _is_units_production_allowed():
		return
	var number_of_pending_units = structure.action.queue.size()
	if number_of_pending_units + _number_of_pending_unit_resource_requests.get(type, 0) == 0:
		resources_required.emit(
			Constants.Match.Units.PRODUCTION_COSTS[unit_scene.resource_path], type
		)
		_number_of_pending_unit_resource_requests[type] = (
			_number_of_pending_unit_resource_requests.get(type, 0) + 1
		)


func _primary_structure():
	var primary_structures = get_tree().get_nodes_in_group("units").filter(
		func(unit): return (
			(
				unit is VehicleFactory
				if _ai.primary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
				else unit is AircraftFactory
			)
			and unit.player == _player
		)
	)
	return primary_structures[0] if not primary_structures.is_empty() else null


func _secondary_structure():
	var secondary_structures = get_tree().get_nodes_in_group("units").filter(
		func(unit): return (
			(
				unit is VehicleFactory
				if _ai.secondary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
				else unit is AircraftFactory
			)
			and unit.player == _player
		)
	)
	return secondary_structures[0] if not secondary_structures.is_empty() else null


func _is_units_production_allowed():
	var primary_structure = _primary_structure()
	var secondary_structure = _secondary_structure()
	return (
		_number_of_additional_units_required()
		> (
			Utils.Arr.sum(_number_of_pending_unit_resource_requests.values())
			+ (primary_structure.action.queue.size() if primary_structure != null else 0)
			+ (secondary_structure.action.queue.size() if secondary_structure != null else 0)
		)
	)


func _number_of_additional_units_required():
	if _battlegroup_under_forming == null:
		return 0
	return (
		_ai.expected_number_of_battlegroups * _ai.expected_number_of_units_in_battlegroup
		- (_battlegroups.size() - 1) * _ai.expected_number_of_units_in_battlegroup
		- _battlegroup_under_forming.size()
	)


func _on_unit_spawned(unit):
	if unit is Tank or unit is Helicopter:
		_battlegroup_under_forming.attach_unit(unit)
		if _battlegroup_under_forming.size() == _ai.expected_number_of_units_in_battlegroup:
			_try_creating_new_battlegroup()
		_enforce_primary_units_production()
		_enforce_secondary_units_production()


func _on_battlegroup_died(battlegroup):
	if not is_inside_tree():
		return
	_battlegroups.erase(battlegroup)


func _on_refresh_timer_timeout():
	_enforce_primary_structure_existence()
	# secondary structure existence is enforced only when a battlegroup is formed
	_enforce_primary_units_production()
	_enforce_secondary_units_production()

# TODO: secondary_structure (built e.g. after first battle group was formed)
# TODO: refresh timer
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

var _player = null
var _primary_structure_scene = null
var _number_of_pending_primary_structure_resource_requests = 0
var _primary_unit_scene = null
var _number_of_pending_primary_unit_resource_requests = 0
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
	_primary_unit_scene = (
		TankScene
		if _ai.primary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
		else HelicopterScene
	)
	_try_creating_new_battlegroup()
	# TODO: attach structures
	# TODO: attach units (form battlegroups)
	MatchSignals.unit_spawned.connect(_on_unit_spawned)
	_enforce_primary_structure_existence()  # TODO: call it in refresh timer
	# TODO: enforce secondary structure existence (?)


func provision(resources, metadata):
	if metadata == "primary_structure":
		assert(
			(
				resources
				== Constants.Match.Units.CONSTRUCTION_COSTS[_primary_structure_scene.resource_path]
			)
		)
		var workers = get_tree().get_nodes_in_group("units").filter(
			func(unit): return unit is Worker and unit.player == _player
		)
		# TODO: fix formatting in gdtoolkit
		_number_of_pending_primary_structure_resource_requests -= 1
		if workers.is_empty():
			return
		_construct_structure(_primary_structure_scene)
	elif metadata == "primary_unit":
		assert(
			resources == Constants.Match.Units.PRODUCTION_COSTS[_primary_unit_scene.resource_path]
		)
		var primary_structure = _get_primary_structure()
		if primary_structure == null or _battlegroup_under_forming == null:
			return
		_number_of_pending_primary_unit_resource_requests -= 1
		primary_structure.action.produce(_primary_unit_scene)
	else:
		assert(false)  # unexpected flow


func _try_creating_new_battlegroup():
	if _battlegroups.size() == _ai.expected_number_of_battlegroups:
		var primary_structure = _get_primary_structure()
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
	var primary_structure = _get_primary_structure()
	if primary_structure == null and _number_of_pending_primary_structure_resource_requests == 0:
		resources_required.emit(
			Constants.Match.Units.CONSTRUCTION_COSTS[_primary_structure_scene.resource_path],
			"primary_structure"
		)
		_number_of_pending_primary_structure_resource_requests += 1


func _enforce_primary_units_production():
	var primary_structure = _get_primary_structure()
	if primary_structure == null:
		return
	var number_of_pending_primary_units = primary_structure.action.queue.size()
	if _number_of_pending_primary_unit_resource_requests + number_of_pending_primary_units == 0:
		resources_required.emit(
			Constants.Match.Units.PRODUCTION_COSTS[_primary_unit_scene.resource_path],
			"primary_unit"
		)
		_number_of_pending_primary_unit_resource_requests += 1


func _get_primary_structure():
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


func _on_unit_spawned(unit):
	if unit is Tank or unit is Helicopter:
		_enforce_primary_units_production()
		_battlegroup_under_forming.attach_unit(unit)
		if _battlegroup_under_forming.size() == _ai.expected_number_of_units_in_battlegroup:
			_try_creating_new_battlegroup()


func _on_battlegroup_died(battlegroup):
	if not is_inside_tree():
		return
	_battlegroups.erase(battlegroup)

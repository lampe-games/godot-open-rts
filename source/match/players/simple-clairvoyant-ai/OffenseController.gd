# TODO: if there are no primary structures - cancel all (?) and build one
# TODO: make sure current offensive structures are busy producing units (multiplex)
# TODO: form battle groups as new units arrive
# TODO: order battle group to attack random player once formed
# TODO: if there are enough units and only one structure - build second one
extends Node

signal resources_required(resources, metadata)

const Worker = preload("res://source/match/units/Worker.gd")
const CommandCenter = preload("res://source/match/units/CommandCenter.gd")
const VehicleFactory = preload("res://source/match/units/VehicleFactory.gd")
const VehicleFactoryScene = preload("res://source/match/units/VehicleFactory.tscn")
const AircraftFactory = preload("res://source/match/units/AircraftFactory.gd")
const AircraftFactoryScene = preload("res://source/match/units/AircraftFactory.tscn")

var _player = null
var _primary_structure_scene = null
var _number_of_pending_primary_structure_resource_requests = 0

@onready var _ai = get_parent()


func setup(player):
	_player = player
	_primary_structure_scene = (
		VehicleFactoryScene
		if _ai.primary_offensive_structure == _ai.OffensiveStructure.VEHICLE_FACTORY
		else AircraftFactoryScene
	)
	# TODO: attach structures
	# TODO: attach units (form battlegroups)
	MatchSignals.unit_spawned.connect(_on_unit_spawned)
	_enforce_primary_structure_existence()
	# TODO: enforce primary structure existence
	# TODO: enforce secondary structure existence (?)


func provision(resources, metadata):
	var workers = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Worker and unit.player == _player
	)
	if metadata == "primary_structure":
		# TODO: fix formatting in gdtoolkit
		assert(
			(
				resources
				== Constants.Match.Units.CONSTRUCTION_COSTS[_primary_structure_scene.resource_path]
			)
		)
		_number_of_pending_primary_structure_resource_requests -= 1
		if workers.is_empty():
			return
		_construct_structure(_primary_structure_scene)
	else:
		assert(false)  # unexpected flow


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
		placement_position + Vector3(0, 0, 1), Vector3.UP
	)
	_player.subtract_resources(construction_cost)
	MatchSignals.setup_and_spawn_unit.emit(structure_scene.instantiate(), target_transform, _player)


func _enforce_primary_structure_existence():
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
	if primary_structures.size() + _number_of_pending_primary_structure_resource_requests == 0:
		resources_required.emit(
			Constants.Match.Units.CONSTRUCTION_COSTS[_primary_structure_scene.resource_path],
			"primary_structure"
		)
		_number_of_pending_primary_structure_resource_requests += 1


func _on_unit_spawned(_unit):
	# TODO: if offensive unit: do stuff
	pass  # TODO: track new offensive units

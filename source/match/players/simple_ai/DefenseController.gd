extends Node

signal resources_required(resources, metadata)

const Worker = preload("res://source/match/units/Worker.gd")
const CommandCenter = preload("res://source/match/units/CommandCenter.gd")
const AGTurret = preload("res://source/match/units/AntiGroundTurret.gd")
const AGTurretScene = preload("res://source/match/units/AntiGroundTurret.tscn")
const AATurret = preload("res://source/match/units/AntiAirTurret.gd")
const AATurretScene = preload("res://source/match/units/AntiAirTurret.tscn")

const REFRESH_INTERVAL = 1.0 / 60.0 * 30.0

var _player = null
var _number_of_pending_ag_turret_resource_requests = 0
var _number_of_pending_aa_turret_resource_requests = 0

@onready var _ai = get_parent()


func setup(player):
	_setup_refresh_timer()
	_player = player
	_attach_current_turrets()
	MatchSignals.unit_spawned.connect(_on_unit_spawned)
	_enforce_number_of_ag_turrets()
	_enforce_number_of_aa_turrets()


func provision(resources, metadata):
	var workers = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Worker and unit.player == _player
	)
	var ccs = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is CommandCenter and unit.player == _player
	)
	if metadata == "ag_turret":
		assert(resources == Constants.Match.Units.CONSTRUCTION_COSTS[AGTurretScene.resource_path])
		_number_of_pending_ag_turret_resource_requests -= 1
		if workers.is_empty() or ccs.is_empty():
			return
		_construct_turret(AGTurretScene)
	elif metadata == "aa_turret":
		assert(resources == Constants.Match.Units.CONSTRUCTION_COSTS[AATurretScene.resource_path])
		_number_of_pending_aa_turret_resource_requests -= 1
		if workers.is_empty() or ccs.is_empty():
			return
		_construct_turret(AATurretScene)
	else:
		assert(false)  # unexpected flow


func _setup_refresh_timer():
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_refresh_timer_timeout)
	timer.start(REFRESH_INTERVAL)


func _attach_current_turrets():
	var turrets = get_tree().get_nodes_in_group("units").filter(
		func(unit): return (unit is AGTurret or unit is AATurret) and unit.player == _player
	)
	for turret in turrets:
		_attach_turret(turret)


func _attach_turret(turret):
	turret.tree_exited.connect(_on_unit_died.bind(turret))


func _enforce_number_of_ag_turrets():
	var ag_turrets = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is AGTurret and unit.player == _player
	)
	if (
		ag_turrets.size() + _number_of_pending_ag_turret_resource_requests
		>= _ai.expected_number_of_ag_turrets
	):
		return
	var number_of_extra_ag_turrets_required = (
		_ai.expected_number_of_ag_turrets
		- (ag_turrets.size() + _number_of_pending_ag_turret_resource_requests)
	)
	for _i in range(number_of_extra_ag_turrets_required):
		resources_required.emit(
			Constants.Match.Units.CONSTRUCTION_COSTS[AGTurretScene.resource_path], "ag_turret"
		)
		_number_of_pending_ag_turret_resource_requests += 1


func _enforce_number_of_aa_turrets():
	var aa_turrets = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is AATurret and unit.player == _player
	)
	if (
		aa_turrets.size() + _number_of_pending_aa_turret_resource_requests
		>= _ai.expected_number_of_aa_turrets
	):
		return
	var number_of_extra_aa_turrets_required = (
		_ai.expected_number_of_aa_turrets
		- (aa_turrets.size() + _number_of_pending_aa_turret_resource_requests)
	)
	for _i in range(number_of_extra_aa_turrets_required):
		resources_required.emit(
			Constants.Match.Units.CONSTRUCTION_COSTS[AATurretScene.resource_path], "aa_turret"
		)
		_number_of_pending_aa_turret_resource_requests += 1


func _construct_turret(turret_scene):
	var construction_cost = Constants.Match.Units.CONSTRUCTION_COSTS[turret_scene.resource_path]
	assert(_player.has_resources(construction_cost))
	var ccs = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is CommandCenter and unit.player == _player
	)
	# TODO: introduce actual algorithm which takes enemy positions into account
	var placement_position = Utils.Match.BuildingPlacement.find_valid_placement_position_radially(
		ccs[0].global_position, 2
	)  # TODO: get radius from somewhere - constants(?)
	var target_transform = Transform3D(Basis(), placement_position).looking_at(
		placement_position + Vector3(0, 0, 1), Vector3.UP
	)
	_player.subtract_resources(construction_cost)
	MatchSignals.setup_and_spawn_unit.emit(turret_scene.instantiate(), target_transform, _player)


func _on_unit_died(unit):
	if not is_inside_tree():
		return
	if unit is AGTurret:
		_enforce_number_of_ag_turrets()
	elif unit is AATurret:
		_enforce_number_of_aa_turrets()
	else:
		assert(false)  # unexpected flow


func _on_unit_spawned(unit):
	if unit is AGTurret or unit is AATurret:
		# TODO: decrease counter
		_attach_turret(unit)


func _on_refresh_timer_timeout():
	_enforce_number_of_ag_turrets()
	_enforce_number_of_aa_turrets()

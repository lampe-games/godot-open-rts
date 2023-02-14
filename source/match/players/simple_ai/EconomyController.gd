# TODO: make sure at least one CC is present
# TODO: make sure workers are always busy
# TODO: make sure there are always enough workers
# TODO: make sure workers collect both resource A and B
extends Node

signal resources_required(resources)

const CommandCenter = preload("res://source/match/units/CommandCenter.gd")
const CommandCenterScene = preload("res://source/match/units/CommandCenter.tscn")
const Worker = preload("res://source/match/units/Worker.gd")
const WorkerScene = preload("res://source/match/units/Worker.tscn")
const CollectingResourcesSequentially = preload(
	"res://source/match/units/actions/CollectingResourcesSequentially.gd"
)

# TODO: get from some config (provided at setup from AI maybe?)
const EXPECTED_NUMBER_OF_WORKERS = 3
const EXPECTED_NUMBER_OF_CCS = 1

var _ccs = []
var _workers = []
var _number_of_pending_cc_resource_requests = 0
var _number_of_pending_worker_resource_requests = 0
var _player = null


func setup(player):
	_player = player
	_attach_current_ccs()
	_attach_current_workers()
	_enforce_number_of_ccs()
	_enforce_number_of_workers()
	# TODO: observe new worker arrivals
	# TODO: observe new CC arrivals


func provision(resources):
	if resources == Constants.Match.Units.PRODUCTION_COSTS[WorkerScene.resource_path]:
		assert(false)  # TODO: request producing new worker
	elif resources == Constants.Match.Units.CONSTRUCTION_COSTS[CommandCenterScene.resource_path]:
		assert(false)  # TODO: implement
	else:
		assert(false)


func _attach_current_ccs():
	_ccs = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is CommandCenter and unit.player == _player
	)
	for cc in _ccs:
		cc.tree_exited.connect(_on_cc_died)


func _attach_current_workers():
	_workers = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Worker and unit.player == _player
	)
	for worker in _workers:
		worker.tree_exited.connect(_on_worker_died)
		worker.action_changed.connect(_on_worker_action_changed.bind(worker))
		if worker.action != null:
			continue
		var closest_resource_unit = (
			CollectingResourcesSequentially
			. find_resource_unit_closest_to_unit_yet_no_further_than(
				worker, Constants.Match.Units.NEW_RESOURCE_SEARCH_RADIUS_M
			)
		)
		if closest_resource_unit != null:
			worker.action = CollectingResourcesSequentially.new(closest_resource_unit)


func _enforce_number_of_ccs():
	if _ccs.size() + _number_of_pending_cc_resource_requests >= EXPECTED_NUMBER_OF_CCS:
		return
	var number_of_extra_ccs_required = (
		EXPECTED_NUMBER_OF_CCS - (_ccs.size() + _number_of_pending_cc_resource_requests)
	)
	for _i in range(number_of_extra_ccs_required):
		resources_required.emit(
			Constants.Match.Units.CONSTRUCTION_COSTS[CommandCenterScene.resource_path]
		)
		_number_of_pending_cc_resource_requests += 1


func _enforce_number_of_workers():
	if _workers.size() + _number_of_pending_worker_resource_requests >= EXPECTED_NUMBER_OF_WORKERS:
		return
	var number_of_extra_workers_required = (
		EXPECTED_NUMBER_OF_WORKERS - (_workers.size() + _number_of_pending_worker_resource_requests)
	)
	for _i in range(number_of_extra_workers_required):
		resources_required.emit(Constants.Match.Units.PRODUCTION_COSTS[WorkerScene.resource_path])
		_number_of_pending_worker_resource_requests += 1


func _on_cc_died():
	_enforce_number_of_ccs()


func _on_worker_died():
	_enforce_number_of_workers()


func _on_worker_action_changed(worker, new_action):
	print("_on_worker_action_changed", worker, " ", new_action)

# TODO: rename to CollectingResourcesWhileInRange
# TODO: add range check
extends "res://source/match/units/actions/Action.gd"

const Worker = preload("res://source/match/units/Worker.gd")
const ResourceUnit = preload("res://source/match/units/non-player/ResourceUnit.gd")

var _resouce_unit = null
var _timer = null

@onready var _unit = Utils.NodeEx.find_parent_with_group(self, "units")


static func is_applicable(source_unit, target_unit):
	# TODO: take range into account
	return (
		source_unit is Worker and target_unit is ResourceUnit and not _worker_is_full(source_unit)
	)


func _init(resource_unit):
	_resouce_unit = resource_unit


func _ready():
	_resouce_unit.tree_exited.connect(queue_free)
	_setup_timer()


func _setup_timer():
	_timer = Timer.new()
	_timer.timeout.connect(_transfer_single_resource_unit_from_resource_to_worker)
	add_child(_timer)
	if "resource_a" in _resouce_unit:
		_timer.start(Constants.Match.Resources.A.COLLECTING_TIME_S)
	elif "resource_b" in _resouce_unit:
		_timer.start(Constants.Match.Resources.B.COLLECTING_TIME_S)


func _transfer_single_resource_unit_from_resource_to_worker():
	if "resource_a" in _resouce_unit:
		_resouce_unit.resource_a -= 1
		_unit.resource_a += 1
	if "resource_b" in _resouce_unit:
		_resouce_unit.resource_b -= 1
		_unit.resource_b += 1
	assert(_unit.resource_a + _unit.resource_b <= _unit.resources_max)
	if _worker_is_full(_unit):
		queue_free()


static func _worker_is_full(worker_unit):
	return worker_unit.resource_a + worker_unit.resource_b == worker_unit.resources_max

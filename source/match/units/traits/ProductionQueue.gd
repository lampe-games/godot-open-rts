extends Node

signal element_enqueued(element)
signal element_removed(element)

const Moving = preload("res://source/match/units/actions/Moving.gd")


class ProductionQueueElement:
	extends Resource
	var unit_prototype = null
	var time_total = null
	var time_left = null:
		set(value):
			time_left = value
			emit_changed()

	func progress():
		return (time_total - time_left) / time_total


var _queue = []

@onready var _unit = get_parent()


func _process(delta):
	while _queue.size() > 0 and delta > 0.0:
		var current_queue_element = _queue.front()
		current_queue_element.time_left = max(0.0, current_queue_element.time_left - delta)
		if current_queue_element.time_left == 0.0:
			_remove_element(current_queue_element)
			_finalize_production(current_queue_element)
		delta = max(0.0, delta - current_queue_element.time_left)


func size():
	return _queue.size()


func get_elements():
	return _queue


func produce(unit_prototype, ignore_limit = false):
	if not ignore_limit and _queue.size() >= Constants.Match.Units.PRODUCTION_QUEUE_LIMIT:
		return
	var production_cost = Constants.Match.Units.PRODUCTION_COSTS[unit_prototype.resource_path]
	if not _unit.player.has_resources(production_cost):
		return
	_unit.player.subtract_resources(production_cost)
	var queue_element = ProductionQueueElement.new()
	queue_element.unit_prototype = unit_prototype
	queue_element.time_total = Constants.Match.Units.PRODUCTION_TIMES[unit_prototype.resource_path]
	queue_element.time_left = Constants.Match.Units.PRODUCTION_TIMES[unit_prototype.resource_path]
	_enqueue_element(queue_element)


func cancel_all():
	for element in _queue.duplicate():
		_remove_element(element)


func _enqueue_element(element):
	_queue.push_back(element)
	element_enqueued.emit(element)


func _remove_element(element):
	_queue.erase(element)
	element_removed.emit(element)


func _finalize_production(former_queue_element):
	var produced_unit = former_queue_element.unit_prototype.instantiate()
	var placement_position = (
		Utils
		. Match
		. Unit
		. Placement
		. find_valid_position_radially_yet_skip_starting_radius(
			_unit.global_position,
			_unit.radius,
			produced_unit.radius,
			0.1,
			Vector3(0, 0, 1),
			false,
			find_parent("Match").navigation.get_navigation_map_rid_by_domain(
				produced_unit.movement_domain
			),
			get_tree()
		)
	)
	MatchSignals.setup_and_spawn_unit.emit(
		produced_unit, Transform3D(Basis(), placement_position), _unit.player
	)

	# Handle rally point
	if _unit.has_node("RallyPoint") and Moving.is_applicable(produced_unit):
		var rally_point = _unit.get_node("RallyPoint").global_position

		if rally_point != _unit.global_position:
			produced_unit.action = Moving.new(rally_point)

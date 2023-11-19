extends Node

signal queue_changed

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


var queue = []

@onready var _unit = get_parent()


func _process(delta):
	while queue.size() > 0 and delta > 0.0:
		var current_queue_element = queue.front()
		current_queue_element.time_left = max(0.0, current_queue_element.time_left - delta)
		if current_queue_element.time_left == 0.0:
			queue.erase(current_queue_element)
			_finalize_production(current_queue_element)
			queue_changed.emit()
			_unit.action_updated.emit()
		delta = max(0.0, delta - current_queue_element.time_left)


func size():
	return queue.size()


func produce(unit_prototype):
	var production_cost = Constants.Match.Units.PRODUCTION_COSTS[unit_prototype.resource_path]
	if not _unit.player.has_resources(production_cost):
		return
	_unit.player.subtract_resources(production_cost)
	var queue_element = ProductionQueueElement.new()
	queue_element.unit_prototype = unit_prototype
	queue_element.time_total = Constants.Match.Units.PRODUCTION_TIMES[unit_prototype.resource_path]
	queue_element.time_left = Constants.Match.Units.PRODUCTION_TIMES[unit_prototype.resource_path]
	queue.push_back(queue_element)
	queue_changed.emit()
	_unit.action_updated.emit()


func cancel_all():
	queue = []
	queue_changed.emit()
	_unit.action_updated.emit()


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

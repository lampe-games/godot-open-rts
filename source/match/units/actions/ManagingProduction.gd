extends "res://source/match/units/actions/Action.gd"

signal queue_changed


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

@onready var _unit = Utils.NodeEx.find_parent_with_group(self, "units")


func _process(delta):
	while queue.size() > 0 and delta > 0.0:
		var current_queue_element = queue.front()
		current_queue_element.time_left = max(0.0, current_queue_element.time_left - delta)
		if current_queue_element.time_left == 0.0:
			queue.erase(current_queue_element)
			_finalize_production(current_queue_element)
			queue_changed.emit()
		delta = max(0.0, delta - current_queue_element.time_left)


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


func _finalize_production(former_queue_element):
	MatchSignals.setup_and_spawn_unit.emit(
		former_queue_element.unit_prototype.instantiate(),
		_unit.global_transform.translated(Vector3(0, 0, 5)),
		_unit.player
	)

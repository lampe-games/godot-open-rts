extends MarginContainer

const ManagingProductionAction = preload("res://source/match/units/actions/ManagingProduction.gd")
const ProductionQueueElement = preload("res://source/match/hud/ProductionQueueElement.tscn")

var _production_manager = null

@onready var _queue_elements = find_child("QueueElements")


func _ready():
	_reset()
	MatchSignals.unit_selected.connect(func(_unit): _reset())
	MatchSignals.unit_deselected.connect(func(_unit): _reset())


func _reset():
	_remove_queue_elements()
	_clear_observed_production_manager()
	if _try_observing_production_manager():
		show()
	else:
		hide()


func _remove_queue_elements():
	for child in _queue_elements.get_children():
		child.queue_free()


func _try_observing_production_manager():
	var selected_controlled_units = _get_selected_controlled_units()
	if selected_controlled_units.size() != 1:
		return false
	var selected_unit = selected_controlled_units[0]
	if selected_unit.action == null or not selected_unit.action is ManagingProductionAction:
		return false
	_observe(selected_unit.action)
	return true


func _clear_observed_production_manager():
	if _production_manager != null:
		_production_manager.queue_changed.disconnect(_on_queue_changed)
		_production_manager = null


func _observe(production_manager):
	_production_manager = production_manager
	_production_manager.queue_changed.connect(_on_queue_changed)
	_render_queue()


func _render_queue():
	var reversed_queue = _production_manager.queue.duplicate()
	reversed_queue.reverse()
	for queue_element in reversed_queue:
		var queue_element_node = ProductionQueueElement.instantiate()
		queue_element_node.queue_element = queue_element
		_queue_elements.add_child(queue_element_node)


func _update_queue():
	if _production_manager.queue.size() > _queue_elements.get_child_count():
		var queue_element = _production_manager.queue.back()
		var queue_element_node = ProductionQueueElement.instantiate()
		queue_element_node.queue_element = queue_element
		_queue_elements.add_child(queue_element_node)
		_queue_elements.move_child(queue_element_node, 0)
		return
	if _production_manager.queue.size() < _queue_elements.get_child_count():
		_queue_elements.get_children()[0].queue_free()


# TODO: deduplicate (create util)
func _get_selected_controlled_units():
	var units = []
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if unit.is_in_group("controlled_units"):
			units.append(unit)
	return units


func _on_queue_changed():
	_update_queue()

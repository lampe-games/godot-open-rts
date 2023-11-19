extends MarginContainer

const ProductionQueueElement = preload("res://source/match/hud/ProductionQueueElement.tscn")

var _production_queue = null

@onready var _queue_elements = find_child("QueueElements")


func _ready():
	_reset()
	MatchSignals.unit_selected.connect(func(_unit): _reset())
	MatchSignals.unit_deselected.connect(func(_unit): _reset())


func _reset():
	if not is_inside_tree():
		return
	_detach_observed_production_queue()
	_try_observing_production_queue()
	visible = _is_observing_production_queue()
	_remove_queue_element_nodes()
	_try_rendering_queue()


func _remove_queue_element_nodes():
	for child in _queue_elements.get_children():
		child.queue_free()


func _is_observing_production_queue():
	return _production_queue != null


func _detach_observed_production_queue():
	if _production_queue != null:
		_production_queue.element_enqueued.disconnect(_on_production_queue_element_enqueued)
		_production_queue.element_removed.disconnect(_on_production_queue_element_removed)
		_production_queue = null


func _try_observing_production_queue():
	var selected_controlled_units = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return unit.is_in_group("controlled_units")
	)
	if selected_controlled_units.size() != 1:
		return
	var selected_unit = selected_controlled_units[0]
	if not "production_queue" in selected_unit or selected_unit.production_queue == null:
		return
	_observe(selected_unit.production_queue)


func _observe(production_queue):
	_production_queue = production_queue
	_production_queue.element_enqueued.connect(_on_production_queue_element_enqueued)
	_production_queue.element_removed.connect(_on_production_queue_element_removed)


func _try_rendering_queue():
	if not _is_observing_production_queue():
		return
	for queue_element in _production_queue.get_elements():
		_add_queue_element_node(queue_element)


func _add_queue_element_node(queue_element):
	var queue_element_node = ProductionQueueElement.instantiate()
	queue_element_node.queue = _production_queue
	queue_element_node.queue_element = queue_element
	_queue_elements.add_child(queue_element_node)
	_queue_elements.move_child(queue_element_node, 0)


func _on_production_queue_element_enqueued(element):
	_add_queue_element_node(element)


func _on_production_queue_element_removed(element):
	(
		_queue_elements
		. get_children()
		. filter(func(queue_element_node): return queue_element_node.queue_element == element)
		. map(func(queue_element_node): queue_element_node.queue_free())
	)

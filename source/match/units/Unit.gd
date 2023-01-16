extends Area3D

signal action_changed(new_action)

var player_id = null:
	set(value):
		assert(player_id == null)
		player_id = value
var action = null:
	set = _set_action

var _action_locked = false


func _ready():
	assert(player_id != null)


func _set_action(action_node):
	if _action_locked:
		return
	_action_locked = true
	_teardown_current_action()
	action = action_node
	if action != null:
		var action_copy = action  # TODO: check if bind creates copy itself - remove if so
		action.tree_exited.connect(_on_action_node_tree_exited.bind(action_copy))
		add_child(action_node)
	_action_locked = false
	action_changed.emit(action)


func _teardown_current_action():
	if action != null and action.is_inside_tree():
		action.queue_free()
		remove_child(action)  # triggers _on_action_node_tree_exited immediately


func _on_action_node_tree_exited(action_node):
	assert(action_node == action)
	action = null

extends Area3D

signal selected
signal deselected
signal hp_changed
signal action_changed(new_action)

# TODO: move setters/getters to separate functions
var hp = null:
	set(value):
		hp = value
		hp_changed.emit()
var hp_max = null:
	set(value):
		hp_max = value
		hp_changed.emit()
var damage = null
var damage_interval = null
var radius = null:
	set(_value):
		pass
	get:
		if find_child("Movement") != null:
			return find_child("Movement").radius
		if find_child("MovementObstacle") != null:
			return find_child("MovementObstacle").radius
		return null

var player_id = null:
	set(value):
		assert(player_id == null)
		player_id = value
var action = null:
	set = _set_action

var _action_locked = false


func _ready():
	assert(player_id != null)
	# TODO: extract to method
	var default_properties = Constants.Match.Units.DEFAULT_PROPERTIES[get_script().resource_path]
	for property in default_properties:
		set(property, default_properties[property])


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

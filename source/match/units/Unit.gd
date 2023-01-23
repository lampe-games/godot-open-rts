extends Area3D

signal selected
signal deselected
signal hp_changed
signal action_changed(new_action)

const MATERIAL_COLOR_TO_REPLACE = Color(0.99, 0.81, 0.48)
const MATERIAL_COLOR_TO_REPLACE_EPSILON = 0.05

var hp = null:
	set = _set_hp
var hp_max = null:
	set = _set_hp_max
var damage = null
var damage_interval = null
var radius = null:
	set = _ignore,
	get = _get_radius
var sight_range = null

var player_id = null:
	set = _set_player_id
var color = null:
	set = _set_color
var action = null:
	set = _set_action

var _action_locked = false


func _ready():
	assert(player_id != null)
	_setup_default_properties_from_constants()


func _ignore(_value):
	pass


func _set_hp(value):
	hp = value
	hp_changed.emit()


func _set_hp_max(value):
	hp_max = value
	hp_changed.emit()


func _get_radius():
	if find_child("Movement") != null:
		return find_child("Movement").radius
	if find_child("MovementObstacle") != null:
		return find_child("MovementObstacle").radius
	return null


func _set_player_id(value):
	assert(player_id == null)
	player_id = value


func _set_color(a_color):
	color = a_color
	# TODO: cache material per player and reuse
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.albedo_color = color
	material.metallic = 1
	var geometry_root = find_child("Geometry")
	if geometry_root == null:
		return
	for child in geometry_root.find_children("*"):
		if not "mesh" in child:
			continue
		for surface_id in range(child.mesh.get_surface_count()):
			var surface_material = child.mesh.get("surface_{0}/material".format([surface_id]))
			if (
				surface_material != null
				and Utils.Colour.is_equal_approx_with_epsilon(
					surface_material.albedo_color,
					MATERIAL_COLOR_TO_REPLACE,
					MATERIAL_COLOR_TO_REPLACE_EPSILON
				)
			):
				child.set("surface_material_override/{0}".format([surface_id]), material)


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


func _setup_default_properties_from_constants():
	var default_properties = Constants.Match.Units.DEFAULT_PROPERTIES[get_script().resource_path]
	for property in default_properties:
		set(property, default_properties[property])


func _on_action_node_tree_exited(action_node):
	assert(action_node == action)
	action = null

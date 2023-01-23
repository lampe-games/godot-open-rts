extends Area3D

signal selected
signal deselected
signal hp_changed
signal action_changed(new_action)

const MATERIAL_COLOR_TO_REPLACE = Color(0.99, 0.81, 0.48)

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
var color = null:
	set = _set_color
var action = null:
	set = _set_action

var _action_locked = false


func _ready():
	assert(player_id != null)
	# TODO: extract to method
	var default_properties = Constants.Match.Units.DEFAULT_PROPERTIES[get_script().resource_path]
	for property in default_properties:
		set(property, default_properties[property])


func _set_color(a_color):
	color = a_color
	# TODO: use path from constants and preload
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
			# TODO: create utility function
			if (
				surface_material != null
				and abs(surface_material.albedo_color.r - MATERIAL_COLOR_TO_REPLACE.r) < 0.1
				and abs(surface_material.albedo_color.g - MATERIAL_COLOR_TO_REPLACE.g) < 0.1
				and abs(surface_material.albedo_color.b - MATERIAL_COLOR_TO_REPLACE.b) < 0.1
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


func _on_action_node_tree_exited(action_node):
	assert(action_node == action)
	action = null

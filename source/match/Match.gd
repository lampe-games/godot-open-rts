extends Node3D

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const Drone = preload("res://source/match/units/Drone.tscn")

@export var settings: Resource = null

var controlled_player_id = null:
	set = _set_controlled_player_id
var visible_player_id = null:
	set = _set_visible_player_id
var visible_player_ids = null:
	set(_value):
		pass
	get:
		return [visible_player_id]

@onready var _camera = find_child("IsometricCamera3D")


func _ready():
	controlled_player_id = settings.controlled_player
	visible_player_id = settings.controlled_player  # TODO: add dedicated field in settings
	_spawn_initial_player_units()
	_move_camera_to_controlled_player_spawn_point()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		MatchSignals.deselect_all.emit()
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		var target_point = get_viewport().get_camera_3d().get_ray_intersection(event.position)
		_navigate_selected_units_towards(target_point)


func _set_controlled_player_id(id):
	MatchSignals.deselect_all.emit()
	_renounce_control_of_player_units(controlled_player_id)
	_assume_control_of_player_units(id)
	controlled_player_id = id


func _set_visible_player_id(id):
	_conceal_player_units(visible_player_id)
	_reveal_player_units(id)
	visible_player_id = id


func _spawn_initial_player_units():
	var spawn_points = find_child("SpawnPoints").get_children()
	for player_id in range(settings.players.size()):
		_spawn_unit(
			CommandCenter.instantiate(), spawn_points[player_id].global_transform, player_id
		)
		_spawn_unit(
			Drone.instantiate(),
			spawn_points[player_id].global_transform.translated(Vector3(2, 5, 2)),
			player_id
		)
		_spawn_unit(
			Drone.instantiate(),
			spawn_points[player_id].global_transform.translated(Vector3(-2, 3, -2)),
			player_id
		)


func _spawn_unit(unit, a_transform, player_id):
	unit.color = settings.players[player_id].color
	unit.global_transform = a_transform
	unit.add_to_group("units")
	unit.add_to_group("player_{0}_units".format([player_id]))
	if player_id == controlled_player_id:
		unit.add_to_group("controlled_units")
	else:
		unit.add_to_group("adversary_units")
	if player_id in visible_player_ids:
		unit.add_to_group("revealed_units")
	add_child(unit)


func _move_camera_to_controlled_player_spawn_point():
	var spawn_points = find_child("SpawnPoints").get_children()
	for player_id in range(settings.players.size()):
		if player_id == controlled_player_id:
			_camera.set_position_safely(spawn_points[player_id].global_transform.origin)
			break


func _assume_control_of_player_units(player_id):
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([player_id])):
		unit.add_to_group("controlled_units")
		unit.remove_from_group("adversary_units")


func _renounce_control_of_player_units(player_id):
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([player_id])):
		unit.add_to_group("adversary_units")
		unit.remove_from_group("controlled_units")


func _reveal_player_units(player_id):
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([player_id])):
		unit.add_to_group("revealed_units")


func _conceal_player_units(player_id):
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([player_id])):
		unit.remove_from_group("revealed_units")


func _navigate_selected_units_towards(target_point):
	for unit in get_tree().get_nodes_in_group("selected_units"):
		var movement_trait = unit.find_child("Movement")
		if movement_trait != null:
			movement_trait.move(target_point)

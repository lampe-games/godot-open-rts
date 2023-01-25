extends Node3D

const Player = preload("res://source/match/model/Player.gd")

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const Drone = preload("res://source/match/units/Drone.tscn")
const Worker = preload("res://source/match/units/Worker.tscn")

@export var settings: Resource = null

var players = []
var controlled_player_id = null:
	set = _set_controlled_player_id
var visible_player_id = null:
	set = _set_visible_player_id
var visible_player_ids = null:
	set(_value):
		pass
	get:
		return [visible_player_id]

@onready var navigation = find_child("Navigation")

@onready var _camera = find_child("IsometricCamera3D")


func _ready():
	MatchSignals.setup_and_spawn_unit.connect(_setup_and_spawn_unit)
	_create_players()
	controlled_player_id = settings.controlled_player
	visible_player_id = settings.visible_player
	_spawn_initial_player_units()
	_move_camera_to_controlled_player_spawn_point()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		MatchSignals.deselect_all_units.emit()


func _set_controlled_player_id(id):
	MatchSignals.deselect_all_units.emit()
	_renounce_control_of_player_units(controlled_player_id)
	_assume_control_of_player_units(id)
	controlled_player_id = id
	MatchSignals.controlled_player_changed.emit(controlled_player_id)


func _set_visible_player_id(id):
	_conceal_player_units(visible_player_id)
	_reveal_player_units(id)
	visible_player_id = id


func _create_players():
	for player_settings in settings.players:
		var player = Player.new()
		player.color = player_settings.color
		players.append(player)


func _spawn_initial_player_units():
	var spawn_points = find_child("SpawnPoints").get_children()
	for player_id in range(settings.players.size()):
		_setup_and_spawn_unit(
			CommandCenter.instantiate(), spawn_points[player_id].global_transform, player_id
		)
		_setup_and_spawn_unit(
			Drone.instantiate(),
			spawn_points[player_id].global_transform.translated(Vector3(2, 5, 2)),
			player_id
		)
		_setup_and_spawn_unit(
			Drone.instantiate(),
			spawn_points[player_id].global_transform.translated(Vector3(-2, 3, -2)),
			player_id
		)
		_setup_and_spawn_unit(
			Worker.instantiate(),
			spawn_points[player_id].global_transform.translated(Vector3(-3, 0, 3)),
			player_id
		)
		_setup_and_spawn_unit(
			Worker.instantiate(),
			spawn_points[player_id].global_transform.translated(Vector3(3, 0, -3)),
			player_id
		)


func _setup_and_spawn_unit(unit, a_transform, player_id):
	unit.player_id = player_id
	unit.player = players[player_id]
	unit.color = unit.player.color
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

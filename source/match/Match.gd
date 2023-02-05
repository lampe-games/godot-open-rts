extends Node3D


class HardcodedMap:
	func get_topdown_polygon_2d():
		return [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)]


const Player = preload("res://source/match/model/Player.gd")

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const Drone = preload("res://source/match/units/Drone.tscn")
const Worker = preload("res://source/match/units/Worker.tscn")
const Helicopter = preload("res://source/match/units/Helicopter.tscn")
const Tank = preload("res://source/match/units/Tank.tscn")
const AGTurret = preload("res://source/match/units/AntiGroundTurret.tscn")

@export var settings: Resource = null

var players = []
var controlled_player = null:
	set = _set_controlled_player
var visible_player = null:
	set = _set_visible_player
var visible_players = null:
	set(_value):
		pass
	get:
		return [visible_player]
var map = HardcodedMap.new()  # TODO: use actual map

@onready var navigation = find_child("Navigation")

@onready var _camera = find_child("IsometricCamera3D")


func _ready():
	MatchSignals.setup_and_spawn_unit.connect(_setup_and_spawn_unit)
	_create_players()
	controlled_player = players[settings.controlled_player]
	visible_player = players[settings.visible_player]
	_setup_player_units()
	_move_camera_to_visible_units_crowd_pivot()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		MatchSignals.deselect_all_units.emit()


func _set_controlled_player(player):
	MatchSignals.deselect_all_units.emit()
	_renounce_control_of_player_units(controlled_player)
	_assume_control_of_player_units(player)
	controlled_player = player
	MatchSignals.controlled_player_changed.emit(controlled_player)


func _set_visible_player(player):
	_conceal_player_units(visible_player)
	_reveal_player_units(player)
	visible_player = player


func _create_players():
	for player_settings in settings.players:
		var player = Player.new()
		player.color = player_settings.color
		players.append(player)


func _setup_player_units():
	var spawn_points = find_child("SpawnPoints").get_children()
	for player_id in range(players.size()):
		var player = players[player_id]
		var predefined_units_root = find_child("Map").find_child("Player{0}".format([player_id]))
		var predefined_units = (
			predefined_units_root.get_children() if predefined_units_root != null else []
		)
		if not predefined_units.is_empty():
			predefined_units.map(func(unit): _setup_unit(unit, player))
		else:
			var spawn_transform = spawn_points[player_id].global_transform
			_spawn_player_units(player, spawn_transform)


func _spawn_player_units(player, spawn_transform):
	_setup_and_spawn_unit(CommandCenter.instantiate(), spawn_transform, player)
	_setup_and_spawn_unit(Drone.instantiate(), spawn_transform.translated(Vector3(2, 5, 2)), player)
	_setup_and_spawn_unit(
		Drone.instantiate(), spawn_transform.translated(Vector3(-2, 3, -2)), player
	)
	_setup_and_spawn_unit(
		Worker.instantiate(), spawn_transform.translated(Vector3(-3, 0, 3)), player
	)
	_setup_and_spawn_unit(
		AGTurret.instantiate(), spawn_transform.translated(Vector3(3, 0, -3)), player
	)
	_setup_and_spawn_unit(Tank.instantiate(), spawn_transform.translated(Vector3(3, 0, 3)), player)
	_setup_and_spawn_unit(
		Helicopter.instantiate(), spawn_transform.translated(Vector3(-3, 0, -3)), player
	)


func _setup_and_spawn_unit(unit, a_transform, player):
	unit.global_transform = a_transform
	_setup_unit(unit, player)
	add_child(unit)


func _setup_unit(unit, player):
	unit.player = player
	unit.color = unit.player.color
	unit.add_to_group("units")
	unit.add_to_group("player_{0}_units".format([players.find(player)]))
	if player == controlled_player:
		unit.add_to_group("controlled_units")
	else:
		unit.add_to_group("adversary_units")
	if player in visible_players:
		unit.add_to_group("revealed_units")


func _move_camera_to_visible_units_crowd_pivot():
	var revealed_units = get_tree().get_nodes_in_group("revealed_units")
	assert(not revealed_units.is_empty())
	var crowd_pivot = Utils.Match.Unit.Movement.calculate_aabb_crowd_pivot_yless(revealed_units)
	_camera.set_position_safely(crowd_pivot)


func _assume_control_of_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([players.find(player)])):
		unit.add_to_group("controlled_units")
		unit.remove_from_group("adversary_units")


func _renounce_control_of_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([players.find(player)])):
		unit.add_to_group("adversary_units")
		unit.remove_from_group("controlled_units")


func _reveal_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([players.find(player)])):
		unit.add_to_group("revealed_units")


func _conceal_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("player_{0}_units".format([players.find(player)])):
		unit.remove_from_group("revealed_units")

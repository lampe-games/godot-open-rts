extends Node3D

const Structure = preload("res://source/match/units/Structure.gd")


class HardcodedMap:
	func get_topdown_polygon_2d():
		return [Vector2(0, 0), Vector2(50, 0), Vector2(50, 50), Vector2(0, 50)]


const Player = preload("res://source/match/model/Player.gd")

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const Drone = preload("res://source/match/units/Drone.tscn")
const Worker = preload("res://source/match/units/Worker.tscn")

@export var settings: Resource = null

var players = []
var controlled_player = null:
	set = _set_controlled_player
var visible_player = null:
	set = _set_visible_player
var visible_players = null:
	set = _ignore,
	get = _get_visible_players
var map = HardcodedMap.new()  # TODO: use actual map

@onready var navigation = find_child("Navigation")

@onready var _camera = find_child("IsometricCamera3D")
@onready var _fog_of_war = find_child("FogOfWar")
@onready var _players = find_child("Players")


func _ready():
	MatchSignals.setup_and_spawn_unit.connect(_setup_and_spawn_unit)
	_create_players()
	_choose_controlled_player()
	visible_player = players[settings.visible_player]
	_setup_player_units()
	_create_and_setup_player_controllers()  # must happen after initial units are created
	_move_camera_to_initial_position()
	if settings.visibility == settings.Visibility.FULL:
		_fog_of_war.reveal()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		MatchSignals.deselect_all_units.emit()


func _ignore(_value):
	pass


func _get_visible_players():
	if settings.visibility == settings.Visibility.PER_PLAYER:
		return [visible_player]
	return players


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


# TODO: refa
func _create_and_setup_player_controllers():
	var existing_player_controllers = _players.get_children()
	for player_id in range(players.size()):
		if player_id < existing_player_controllers.size():
			var existing_player_controller = existing_player_controllers[player_id]
			if not existing_player_controller.name.begins_with("Placeholder"):
				if "player" in existing_player_controller:
					existing_player_controller.player = players[player_id]
				continue
		var player_controller = settings.players[player_id].controller
		if player_controller == Constants.PlayerController.NONE:
			continue
		assert(
			player_controller != Constants.PlayerController.DETECT_FROM_SCENE,
			"cannot detect existing player controller"
		)
		var controller_scene = {
			Constants.PlayerController.HUMAN:
			preload("res://source/match/players/human/Human.tscn"),
			Constants.PlayerController.SIMPLE_CLAIRVOYANT_AI:
			preload("res://source/match/players/simple-clairvoyant-ai/SimpleClairvoyantAI.tscn"),
		}[player_controller]
		var controller_node = controller_scene.instantiate()
		if "player" in controller_node:
			controller_node.player = players[player_id]
		_players.add_child(controller_node)


func _choose_controlled_player():
	for player_id in range(players.size()):
		if settings.players[player_id].controller == Constants.PlayerController.HUMAN:
			assert(controlled_player == null, "more than one human player in settings")
			controlled_player = players[player_id]


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


func _move_camera_to_initial_position():
	if controlled_player != null:
		_move_camera_to_player_units_crowd_pivot(controlled_player)
	else:
		_move_camera_to_player_units_crowd_pivot(players[0])


func _spawn_player_units(player, spawn_transform):
	_setup_and_spawn_unit(CommandCenter.instantiate(), spawn_transform, player, false)
	_setup_and_spawn_unit(
		Drone.instantiate(), spawn_transform.translated(Vector3(-2, 0, -2)), player
	)
	_setup_and_spawn_unit(
		Worker.instantiate(), spawn_transform.translated(Vector3(-3, 0, 3)), player
	)
	_setup_and_spawn_unit(
		Worker.instantiate(), spawn_transform.translated(Vector3(3, 0, 3)), player
	)


func _setup_and_spawn_unit(unit, a_transform, player, mark_structure_under_construction = true):
	unit.global_transform = a_transform
	_setup_unit(unit, player)
	if unit is Structure and mark_structure_under_construction:
		unit.mark_as_under_construction()
	add_child(unit)
	MatchSignals.unit_spawned.emit(unit)


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


func _move_camera_to_player_units_crowd_pivot(player):
	var player_units = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit.player == player
	)
	assert(not player_units.is_empty(), "player must have at least one initial unit")
	var crowd_pivot = Utils.Match.Unit.Movement.calculate_aabb_crowd_pivot_yless(player_units)
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

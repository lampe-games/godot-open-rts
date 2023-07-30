extends Node3D

const Structure = preload("res://source/match/units/Structure.gd")
const Player = preload("res://source/match/model/Player.gd")

const HumanController = preload("res://source/match/players/human/Human.tscn")
const SimpleClairvoyantAIController = preload(
	"res://source/match/players/simple-clairvoyant-ai/SimpleClairvoyantAI.tscn"
)

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const Drone = preload("res://source/match/units/Drone.tscn")
const Worker = preload("res://source/match/units/Worker.tscn")

@export var settings: Resource = null
@export var map_to_load_and_plug: PackedScene = null
@export var map_to_plug: Node = null

var players = []
var controlled_player = null:
	set = _set_controlled_player
var visible_player = null:
	set = _set_visible_player
var visible_players = null:
	set = _ignore,
	get = _get_visible_players

@onready var map = $Map
@onready var navigation = $Navigation
@onready var fog_of_war = $FogOfWar

@onready var _camera = $IsometricCamera3D
@onready var _players = $Players
@onready var _predefined_units = $Units
@onready var _terrain = $Terrain


func _ready():
	_try_setting_up_a_custom_map()
	MatchSignals.setup_and_spawn_unit.connect(_setup_and_spawn_unit)
	_create_players()
	_choose_controlled_player()
	visible_player = players[settings.visible_player]
	_setup_player_units()
	_create_and_setup_player_controllers()  # must happen after initial units are created
	_move_camera_to_initial_position()
	if settings.visibility == settings.Visibility.FULL:
		fog_of_war.reveal()


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
	if controlled_player != null:
		# remove controller of old controlled_player
		(
			_players
			. get_children()
			. filter(func(controller): return controller.player == controlled_player)[0]
			. queue_free()
		)
		# add AI controller for old controlled_player
		var ai_controller = SimpleClairvoyantAIController.instantiate()
		ai_controller.player = controlled_player
		_players.add_child(ai_controller)
	controlled_player = player
	if controlled_player != null:
		# if new controlled_player had some controller before, remove it
		var found_controllers = _players.get_children().filter(
			func(controller): return (
				not controller.name.begins_with("Placeholder")
				and controller.player == controlled_player
			)
		)
		if not found_controllers.is_empty():
			found_controllers[0].queue_free()
		# and create human controller for new controller_player
		var human_controller = HumanController.instantiate()
		human_controller.player = controlled_player
		_players.add_child(human_controller)
	MatchSignals.controlled_player_changed.emit(controlled_player)


func _set_visible_player(player):
	_conceal_player_units(visible_player)
	_reveal_player_units(player)
	visible_player = player


func _try_setting_up_a_custom_map():
	assert(
		map_to_load_and_plug == null or map_to_plug == null,
		"both 'map_to_load_and_plug' and 'map_to_plug' cannot be set at the same time"
	)
	if map_to_load_and_plug == null and map_to_plug == null:
		return
	var custom_map = map_to_plug if map_to_plug != null else map_to_load_and_plug.instantiate()
	if custom_map != null:
		_plug_custom_map(custom_map)
		_terrain.update_shape(custom_map.find_child("Terrain").mesh)
		fog_of_war.resize(custom_map.size)
		_recalculate_camera_bounding_planes(custom_map.size)
		navigation.rebake(custom_map)


func _recalculate_camera_bounding_planes(map_size: Vector2):
	_camera.bounding_planes[1] = Plane(-1, 0, 0, -map_size.x)
	_camera.bounding_planes[3] = Plane(0, 0, -1, -map_size.y)


func _plug_custom_map(custom_map):
	map.name = map.name + "1"
	map.add_sibling(custom_map)
	remove_child(map)
	map.queue_free()
	map = custom_map
	map.owner = self


func _create_players():
	for player_settings in settings.players:
		var player = Player.new()
		player.color = player_settings.color
		players.append(player)


func _create_and_setup_player_controllers():
	var existing_player_controllers = _players.get_children()
	for player_id in range(players.size()):
		var pending_placeholder = null
		if player_id < existing_player_controllers.size():
			var detected_player_controller = existing_player_controllers[player_id]
			if not detected_player_controller.name.begins_with("Placeholder"):
				detected_player_controller.player = players[player_id]
				continue
			else:
				pending_placeholder = detected_player_controller
		var desired_player_controller = settings.players[player_id].controller
		assert(
			desired_player_controller != Constants.PlayerController.DETECT_FROM_SCENE,
			"cannot detect existing player controller"
		)
		if desired_player_controller == Constants.PlayerController.NONE:
			continue
		var controller_scene = Constants.Match.Player.CONTROLLER_SCENES[desired_player_controller]
		var controller_node = controller_scene.instantiate()
		controller_node.player = players[player_id]
		if pending_placeholder != null:
			pending_placeholder.add_sibling(controller_node)
			pending_placeholder.queue_free()
		else:
			_players.add_child(controller_node)


func _choose_controlled_player():
	for player_id in range(players.size()):
		if settings.players[player_id].controller == Constants.PlayerController.HUMAN:
			assert(controlled_player == null, "more than one human player in settings")
			controlled_player = players[player_id]


func _caclulate_player_to_spawn_point_mapping():
	var player_to_spawn_point_mapping = {}
	var spawn_points = map.find_child("SpawnPoints").get_children()
	var unassigned_spawn_point_indexes = range(spawn_points.size())
	for player_id in range(players.size()):
		var player = players[player_id]
		if settings.players[player_id].spawn_index != -1:
			assert(
				settings.players[player_id].spawn_index in unassigned_spawn_point_indexes,
				"another player already assigned to this spawn position"
			)
			player_to_spawn_point_mapping[player] = spawn_points[
				settings.players[player_id].spawn_index
			]
			unassigned_spawn_point_indexes.erase(settings.players[player_id].spawn_index)
	for player_id in range(players.size()):
		var player = players[player_id]
		if settings.players[player_id].spawn_index == -1:
			var spawn_point_index = unassigned_spawn_point_indexes.pop_front()
			player_to_spawn_point_mapping[player] = spawn_points[spawn_point_index]
	return player_to_spawn_point_mapping


func _setup_player_units():
	var player_to_spawn_point_mapping = _caclulate_player_to_spawn_point_mapping()
	for player_id in range(players.size()):
		var player = players[player_id]
		var predefined_units_root = _predefined_units.find_child("Player{0}".format([player_id]))
		var predefined_units = (
			predefined_units_root.get_children() if predefined_units_root != null else []
		)
		if not predefined_units.is_empty():
			predefined_units.map(func(unit): _setup_unit(unit, player))
		else:
			_spawn_player_units(player, player_to_spawn_point_mapping[player].global_transform)


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
	for unit in get_tree().get_nodes_in_group("units").filter(
		func(a_unit): return a_unit.player == player
	):
		unit.add_to_group("controlled_units")
		unit.remove_from_group("adversary_units")


func _renounce_control_of_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("units").filter(
		func(a_unit): return a_unit.player == player
	):
		unit.add_to_group("adversary_units")
		unit.remove_from_group("controlled_units")


func _reveal_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("units").filter(
		func(a_unit): return a_unit.player == player
	):
		unit.add_to_group("revealed_units")


func _conceal_player_units(player):
	if player == null:
		return
	for unit in get_tree().get_nodes_in_group("units").filter(
		func(a_unit): return a_unit.player == player
	):
		unit.remove_from_group("revealed_units")

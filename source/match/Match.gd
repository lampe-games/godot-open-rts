extends Node3D

const Unit = preload("res://source/match/units/Unit.gd")
const Structure = preload("res://source/match/units/Structure.gd")
const Player = preload("res://source/match/players/Player.gd")
const Human = preload("res://source/match/players/human/Human.gd")

# const HumanController = preload("res://source/match/players/human/Human.tscn")
# const SimpleClairvoyantAIController = preload(
# 	"res://source/match/players/simple-clairvoyant-ai/SimpleClairvoyantAI.tscn"
# )

const CommandCenter = preload("res://source/match/units/CommandCenter.tscn")
const Drone = preload("res://source/match/units/Drone.tscn")
const Worker = preload("res://source/match/units/Worker.tscn")

@export var settings: Resource = null

var map:
	set = _set_map,
	get = _get_map
var players: Array:
	set = _ignore,
	get = _get_players
var controlled_player = null:
	set = _set_controlled_player
var visible_player = null:
	set = _set_visible_player
var visible_players = null:
	set = _ignore,
	get = _get_visible_players

@onready var navigation = $Navigation
@onready var fog_of_war = $FogOfWar

@onready var _camera = $IsometricCamera3D
@onready var _players = $Players
@onready var _terrain = $Terrain


func _enter_tree():
	assert(settings != null, "match cannot start without settings, see examples in tests/manual/")
	assert(map != null, "match cannot start without map, see examples in tests/manual/")
	# TODO: remove - it's a temporary hack
	$Players.get_children().filter(func(node): return node is Player).map(
		func(player): player.add_to_group("players")
	)


func _ready():
	MatchSignals.setup_and_spawn_unit.connect(_setup_and_spawn_unit)
	_setup_subsystems_dependent_on_map()
	_setup_players()
	_setup_player_units()
	controlled_player = _get_human_player()
	visible_player = players[settings.visible_player]
	_move_camera_to_initial_position()
	if settings.visibility == settings.Visibility.FULL:
		fog_of_war.reveal()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.is_action_pressed("shift_selecting"):
			return
		MatchSignals.deselect_all_units.emit()


func _set_map(a_map):
	assert(get_node_or_null("Map") == null, "map already set")
	a_map.name = "Map"
	add_child(a_map)
	a_map.owner = self


func _ignore(_value):
	pass


func _get_map():
	return get_node_or_null("Map")


func _get_players():
	return get_tree().get_nodes_in_group("players")


func _set_controlled_player(player):
	MatchSignals.deselect_all_units.emit()
	_renounce_control_of_player_units(controlled_player)
	_assume_control_of_player_units(player)
	assert(controlled_player == null, "not implemented")
	# if controlled_player != null:
	# 	# remove controller of old controlled_player
	# 	(
	# 		_players
	# 		. get_children()
	# 		. filter(func(controller): return controller.player == controlled_player)[0]
	# 		. queue_free()
	# 	)
	# 	# add AI controller for old controlled_player
	# 	var ai_controller = SimpleClairvoyantAIController.instantiate()
	# 	ai_controller.player = controlled_player
	# 	_players.add_child(ai_controller)
	controlled_player = player
	# if controlled_player != null:
	# 	# if new controlled_player had some controller before, remove it
	# 	var found_controllers = _players.get_children().filter(
	# 		func(controller): return (
	# 			not controller.name.begins_with("Placeholder")
	# 			and controller.player == controlled_player
	# 		)
	# 	)
	# 	if not found_controllers.is_empty():
	# 		found_controllers[0].queue_free()
	# 	# and create human controller for new controller_player
	# 	var human_controller = HumanController.instantiate()
	# 	human_controller.player = controlled_player
	# 	_players.add_child(human_controller)
	MatchSignals.controlled_player_changed.emit(controlled_player)


func _set_visible_player(player):
	_conceal_player_units(visible_player)
	_reveal_player_units(player)
	visible_player = player


func _get_visible_players():
	if settings.visibility == settings.Visibility.PER_PLAYER:
		return [visible_player]
	return players


func _setup_subsystems_dependent_on_map():
	_terrain.update_shape(map.find_child("Terrain").mesh)
	fog_of_war.resize(map.size)
	_recalculate_camera_bounding_planes(map.size)
	navigation.rebake(map)


func _recalculate_camera_bounding_planes(map_size: Vector2):
	_camera.bounding_planes[1] = Plane(-1, 0, 0, -map_size.x)
	_camera.bounding_planes[3] = Plane(0, 0, -1, -map_size.y)


func _setup_players():
	assert(
		_players.get_children().is_empty() or settings.players.is_empty(),
		"players can be defined either in settings or in scene tree, not in both"
	)
	if _players.get_children().is_empty():
		_create_players_from_settings()
	for node in _players.get_children():
		if node is Player:
			node.add_to_group("players")


func _create_players_from_settings():
	for player_settings in settings.players:
		var player_scene = Constants.Match.Player.CONTROLLER_SCENES[player_settings.controller]
		var player = player_scene.instantiate()
		player.color = player_settings.color
		if player_settings.spawn_index_offset > 0:
			for _i in range(player_settings.spawn_index_offset):
				_players.add_child(Node.new())
		_players.add_child(player)


func _setup_player_units():
	for player in _players.get_children():
		if not player is Player:
			continue
		var player_index = player.get_index()
		var predefined_units = player.get_children().filter(func(child): return child is Unit)
		if not predefined_units.is_empty():
			predefined_units.map(func(unit): _setup_unit(unit, player))
		else:
			_spawn_player_units(
				player, map.find_child("SpawnPoints").get_child(player_index).global_transform
			)


func _get_human_player():
	var human_players = get_tree().get_nodes_in_group("players").filter(
		func(player): return player is Human
	)
	assert(human_players.size() <= 1, "more than one human player is not allowed")
	if not human_players.is_empty():
		return human_players[0]
	return null


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


func _move_camera_to_initial_position():
	if controlled_player != null:
		_move_camera_to_player_units_crowd_pivot(controlled_player)
	else:
		_move_camera_to_player_units_crowd_pivot(players[0])


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

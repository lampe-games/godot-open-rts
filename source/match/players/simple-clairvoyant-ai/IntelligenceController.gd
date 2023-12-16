extends Node

const TARGET_SWITICHING_TIME_MIN_S = 0.5
const TARGET_SWITICHING_TIME_MAX_S = 1.0


class Actions:
	const MovingToUnit = preload("res://source/match/units/actions/MovingToUnit.gd")


const Drone = preload("res://source/match/units/Drone.gd")

var _player = null
var _blacklisted_drone_target_paths = {}


func setup(player):
	_player = player
	_attach_current_drones()
	_initialize_movement_of_current_drones()


func _attach_current_drones():
	for drone in _get_current_drones():
		_attach_drone(drone)


func _initialize_movement_of_current_drones():
	for drone in _get_current_drones():
		_navigate_to_random_unit(drone)


func _get_current_drones():
	return get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Drone and unit.player == _player
	)


func _attach_drone(drone):
	drone.action_changed.connect(_on_drone_action_changed.bind(drone))


func _navigate_to_random_unit(drone):
	var players_in_random_order = get_tree().get_nodes_in_group("players").filter(
		func(player): return player != _player
	)
	players_in_random_order.shuffle()
	var random_player_to_visit = players_in_random_order.front()
	var random_player_units_in_random_order = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit.player == random_player_to_visit
	)
	var blacklisted_drone_target_path = _blacklisted_drone_target_paths.get(drone, NodePath())
	random_player_units_in_random_order = random_player_units_in_random_order.filter(
		func(unit): return unit.get_path() != blacklisted_drone_target_path
	)
	random_player_units_in_random_order.shuffle()
	if not random_player_units_in_random_order.is_empty():
		var target_unit = random_player_units_in_random_order.front()
		_blacklisted_drone_target_paths[drone] = target_unit.get_path()
		drone.action = Actions.MovingToUnit.new(target_unit)
	else:
		var units_in_random_order = get_tree().get_nodes_in_group("units").filter(
			func(unit): return unit.player != _player
		)
		units_in_random_order.shuffle()
		units_in_random_order = units_in_random_order.filter(
			func(unit): return unit.get_path() != blacklisted_drone_target_path
		)
		if not units_in_random_order.is_empty():
			var target_unit = units_in_random_order.front()
			_blacklisted_drone_target_paths[drone] = target_unit.get_path()
			drone.action = Actions.MovingToUnit.new(target_unit)


func _on_drone_action_changed(new_action, drone):
	if new_action == null:
		await (
			get_tree()
			. create_timer(randf_range(TARGET_SWITICHING_TIME_MIN_S, TARGET_SWITICHING_TIME_MAX_S))
			. timeout
		)
		var drone_was_freed = not is_instance_valid(drone)
		if drone_was_freed:
			return
		_navigate_to_random_unit(drone)

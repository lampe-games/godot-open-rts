extends Node

const Structure = preload("res://source/match/units/Structure.gd")
const Worker = preload("res://source/match/units/Worker.gd")
const Constructing = preload("res://source/match/units/actions/Constructing.gd")

const REFRESH_INTERVAL_S = 1.0 / 60.0 * 30.0

var _player = null


func setup(player):
	_player = player
	_setup_refresh_timer()


func _setup_refresh_timer():
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_refresh_timer_timeout)
	timer.start(REFRESH_INTERVAL_S)


func _on_refresh_timer_timeout():
	var workers = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Worker and unit.player == _player
	)
	if workers.any(func(worker): return worker.action != null and worker.action is Constructing):
		return
	var structures_to_construct = get_tree().get_nodes_in_group("units").filter(
		func(unit):
			return unit is Structure and not unit.is_constructed() and unit.player == _player
	)
	if not structures_to_construct.is_empty() and not workers.is_empty():
		# TODO: introduce some algortihm based on distances
		workers.shuffle()
		structures_to_construct.shuffle()
		workers[0].action = Constructing.new(structures_to_construct[0])

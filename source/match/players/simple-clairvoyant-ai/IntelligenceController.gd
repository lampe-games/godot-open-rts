extends Node

const Drone = preload("res://source/match/units/Drone.gd")

var _player = null


func setup(player):
	_player = player
	_attach_current_drones()


func _attach_current_drones():
	var drones = get_tree().get_nodes_in_group("units").filter(
		func(unit): return unit is Drone and unit.player == _player
	)
	for drone in drones:
		_attach_drone(drone)


func _attach_drone(drone):
	# TODO: select random player's units -> if units: move to spot -> if not: select all units
	# and repeat
	print("_attach_drone ", drone)

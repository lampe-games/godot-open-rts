# TODO: make sure there are enough turrets
extends Node

signal resources_required(resources, metadata)

const AGTurret = preload("res://source/match/units/AntiGroundTurret.gd")
const AATurret = preload("res://source/match/units/AntiAirTurret.gd")

var _player = null
var _number_of_pending_ag_turret_resource_requests = 0
var _number_of_pending_aa_turret_resource_requests = 0


func setup(player):
	_player = player
	_attach_current_turrets()
	MatchSignals.unit_spawned.connect(_on_unit_spawned)
	# _enforce_number_of_ag_turrets()
	# _enforce_number_of_aa_turrets()


func provision(_resources, _metadata):
	assert(false)


func _attach_current_turrets():
	var turrets = get_tree().get_nodes_in_group("units").filter(
		func(unit): return (unit is AGTurret or unit is AATurret) and unit.player == _player
	)
	for turret in turrets:
		_attach_turret(turret)


func _attach_turret(turret):
	turret.tree_exited.connect(_on_unit_died.bind(turret))


func _enforce_number_of_ag_turrets():
	assert(false)


func _enforce_number_of_aa_turrets():
	assert(false)


func _on_unit_died(unit):
	if unit is AGTurret:
		_enforce_number_of_ag_turrets()
	elif unit is AATurret:
		_enforce_number_of_aa_turrets()
	else:
		assert(false)  # unexpected flow


func _on_unit_spawned(unit):
	if unit is AGTurret or unit is AATurret:
		# TODO: decrease counter
		_attach_turret(unit)

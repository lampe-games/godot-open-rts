# TODO: implement FSM using sub-actions:
# 1. moving to resource (or closest resource if original is gone)
# 2. collecting
# 3. moving to closest CC
# 4. adding collected resources to player resources
# back to 1.
extends "res://source/match/units/actions/Action.gd"

const Worker = preload("res://source/match/units/Worker.gd")

var _accumulated_delta = 0.0
var _resouce_unit = null

@onready var _unit = Utils.NodeEx.find_parent_with_group(self, "units")


static func is_applicable(source_unit, target_unit):
	return source_unit is Worker and target_unit.is_in_group("resource_units")


func _init(resource_unit):
	_resouce_unit = resource_unit


func _process(delta):
	# TODO: change dummy algorithm to actual one
	_accumulated_delta += delta
	if _accumulated_delta < 1.0:
		return
	_accumulated_delta -= 1.0
	if "resource_a" in _resouce_unit:
		_resouce_unit.resource_a -= 1
		_unit.player.resource_a += 1
	if "resource_b" in _resouce_unit:
		_resouce_unit.resource_b -= 1
		_unit.player.resource_b += 1

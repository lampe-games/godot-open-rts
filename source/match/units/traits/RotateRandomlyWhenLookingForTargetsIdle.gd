extends Node

const WaitingForTargets = preload("res://source/match/units/actions/WaitingForTargets.gd")

const ROTATION_MULTIPLIER_MARKOVIAN_TRANSITIONS = {
	0:
	{
		0: 0.97,
		1: 0.015,
		-1: 0.015,
	},
	1:
	{
		0: 0.02,
		1: 0.98,
		-1: 0.0,
	},
	-1:
	{
		0: 0.02,
		1: 0.0,
		-1: 0.98,
	},
}

@export var node_to_rotate: NodePath
@export var rotation_speed = 120.0  # degrees/s

var _current_rotation_multiplier = 0

@onready var _unit = get_parent()


func _physics_process(delta):
	_calculate_new_rotation_multiplier()
	if (
		get_node_or_null(node_to_rotate) != null
		and _unit.action is WaitingForTargets
		and _unit.action.is_idle()
	):
		get_node_or_null(node_to_rotate).global_rotation_degrees.y += (
			rotation_speed * delta * _current_rotation_multiplier
		)


func _calculate_new_rotation_multiplier():
	var roulette_wheel = Utils.RouletteWheel.new(
		ROTATION_MULTIPLIER_MARKOVIAN_TRANSITIONS[_current_rotation_multiplier]
	)
	_current_rotation_multiplier = roulette_wheel.get_value(randf())

extends Node

const WaitingForTargets = preload("res://source/match/units/actions/WaitingForTargets.gd")
const Structure = preload("res://source/match/units/Structure.gd")

const ROTATION_MULTIPLIER_CHANGE_INTERVAL_LB_S = 0.2
const ROTATION_MULTIPLIER_CHANGE_INTERVAL_UB_S = 0.8

@export var node_to_rotate: NodePath
@export var rotation_speed = 120.0  # degrees/s

var _current_rotation_multiplier = 0

@onready var _unit = get_parent()
@onready var _timer = find_child("Timer")


func _ready():
	_timer.timeout.connect(_on_rotation_multiplier_change_timer_timeout)
	_timer.start(
		randf_range(
			ROTATION_MULTIPLIER_CHANGE_INTERVAL_LB_S, ROTATION_MULTIPLIER_CHANGE_INTERVAL_UB_S
		)
	)


func _physics_process(delta):
	if _unit is Structure and not _unit.is_constructed():
		return
	if (
		get_node_or_null(node_to_rotate) != null
		and _unit.action is WaitingForTargets
		and _unit.action.is_idle()
	):
		get_node_or_null(node_to_rotate).global_rotation_degrees.y += (
			rotation_speed * delta * _current_rotation_multiplier
		)


func _on_rotation_multiplier_change_timer_timeout():
	_current_rotation_multiplier = randi_range(-1, 1)
	_timer.start(
		randf_range(
			ROTATION_MULTIPLIER_CHANGE_INTERVAL_LB_S, ROTATION_MULTIPLIER_CHANGE_INTERVAL_UB_S
		)
	)

extends "res://source/match/units/actions/Moving.gd"

var _target_unit = null


func _init(target_unit):
	_target_unit = target_unit


func _ready():
	var target_to_unit_direction = (
		(_unit.global_position * Vector3(1, 0, 1) - _target_unit.global_position * Vector3(1, 0, 1))
		. normalized()
	)
	# TODO: use sum of radiuses instead of _movement_trait.radius * 2.0
	_target_position = (
		_target_unit.global_position + target_to_unit_direction * _movement_trait.radius * 2.0
	)
	super()

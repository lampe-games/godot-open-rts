# TODO: teardown only if units adhere
# TODO: handle unit death
# TODO: consider making more complex version of this action
extends "res://source/match/units/actions/Moving.gd"

var _target_unit = null


func _init(target_unit):
	_target_unit = target_unit


func _ready():
	var target_to_unit_direction = (
		(_unit.global_position * Vector3(1, 0, 1) - _target_unit.global_position * Vector3(1, 0, 1))
		. normalized()
	)
	_target_position = (
		_target_unit.global_position
		+ (
			target_to_unit_direction
			* (_unit.radius + _target_unit.radius + Constants.Match.Units.ADHERENCE_MARGIN)
		)
	)
	super()

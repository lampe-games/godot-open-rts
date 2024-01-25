extends "res://source/match/units/actions/Moving.gd"

var _target_unit = null


func _init(target_unit):
	_target_unit = target_unit


func _process(_delta):
	if Utils.Match.Unit.Movement.units_adhere(_unit, _target_unit):
		queue_free()


func _ready():
	_target_unit.tree_exited.connect(queue_free)
	_target_position = (
		_target_unit.global_position_yless
		+ (
			(_unit.global_position_yless - _target_unit.global_position_yless).normalized()
			* _target_unit.radius
		)
	)
	super()


func _on_movement_finished():
	if Utils.Match.Unit.Movement.units_adhere(_unit, _target_unit):
		queue_free()
	else:
		_target_position = _target_unit.global_position
		_movement_trait.move(_target_position)

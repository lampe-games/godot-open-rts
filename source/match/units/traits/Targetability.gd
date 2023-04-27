@tool
extends Node3D

const ANIMATION_DURATION_S = 0.3
const RADIUS_DEVIATION_FACTOR = 0.1

@export_range(0.001, 50.0) var radius = 1.0:
	set = _set_radius
@export_range(0.001, 50.0) var width = 5.0:
	set = _set_width

var _tween = null

@onready var _unit = get_parent()
@onready var _circle = find_child("Circle3D")


func _ready():
	_update_circle_params()
	if Engine.is_editor_hint():
		return
	_unit.input_event.connect(_on_input_event)
	_circle.hide()


func animate():
	_update_circle_params()
	_update_circle_color()
	_circle.show()
	if _tween != null and _tween.is_valid() and _tween.is_running():
		_tween.stop()
		_tween.play()
		return
	_tween = get_tree().create_tween()
	(
		_tween
		. tween_property(
			_circle, "radius", _circle.radius * RADIUS_DEVIATION_FACTOR, ANIMATION_DURATION_S
		)
		. set_ease(Tween.EASE_IN)
		. set_trans(Tween.TRANS_LINEAR)
	)
	_tween.tween_callback(_circle.hide).set_delay(ANIMATION_DURATION_S)


func _update_circle_color():
	if _unit.is_in_group("controlled_units"):
		_circle.color = Constants.Match.OWNED_PLAYER_CIRCLE_COLOR
	elif _unit.is_in_group("adversary_units"):
		_circle.color = Constants.Match.ADVERSARY_PLAYER_CIRCLE_COLOR
	elif _unit.is_in_group("resource_units"):
		_circle.color = Constants.Match.RESOURCE_CIRCLE_COLOR
	else:
		_circle.color = Constants.Match.DEFAULT_CIRCLE_COLOR


func _update_circle_params():
	if _circle == null:
		return
	_circle.radius = radius
	_circle.width = width


func _set_radius(a_radius):
	radius = a_radius
	_update_circle_params()


func _set_width(a_width):
	width = a_width
	_update_circle_params()


func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		MatchSignals.unit_targeted.emit(_unit)

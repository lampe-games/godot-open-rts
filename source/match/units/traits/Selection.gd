@tool
extends Node3D

@export_range(0.001, 50.0) var radius = 1.0:
	set = _set_radius
@export_range(0.001, 50.0) var width = 10.0:
	set = _set_width

var _selected = false

@onready var _unit = get_parent()
@onready var _circle = find_child("FadedCircle3D")


func _ready():
	_update_circle_params()
	if Engine.is_editor_hint():
		return
	MatchSignals.deselect_all_units.connect(deselect)
	_unit.input_event.connect(_on_input_event)
	_circle.hide()


func select():
	if _selected:
		return
	_selected = true
	if not _unit.is_in_group("selected_units"):
		_unit.add_to_group("selected_units")
	_update_circle_color()
	_circle.show()
	if "selected" in _unit:
		_unit.selected.emit()
	MatchSignals.unit_selected.emit(_unit)


func deselect():
	if not _selected:
		return
	_selected = false
	if _unit.is_in_group("selected_units"):
		_unit.remove_from_group("selected_units")
	_circle.hide()
	if "deselected" in _unit:
		_unit.deselected.emit()
	MatchSignals.unit_deselected.emit(_unit)


func _set_radius(a_radius):
	radius = a_radius
	_update_circle_params()


func _set_width(a_width):
	width = a_width
	_update_circle_params()


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
	_circle.inner_edge_width = width


func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _selected and Input.is_action_pressed("shift_selecting"):
			deselect()
			return
		select()

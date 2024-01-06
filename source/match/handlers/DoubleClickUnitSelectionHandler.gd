extends Node3D

const DOUBLE_CLICK_LB_MS = 50
const DOUBLE_CLICK_UB_MS = 600

var _last_unit_selected = null
var _last_unit_selected_timestamp = 0


func _ready():
	MatchSignals.unit_selected.connect(_on_unit_selected)


func _handle_double_click(unit_type):
	var units_to_select = Utils.Set.new()
	var camera = get_viewport().get_camera_3d()
	for unit in get_tree().get_nodes_in_group("controlled_units"):
		if not unit.visible or not camera.is_position_in_frustum(unit.global_position):
			continue
		if unit.type == unit_type:
			units_to_select.add(unit)
	Utils.Match.select_units(units_to_select)


func _on_unit_selected(unit):
	if not unit.is_in_group("controlled_units"):
		return
	if Time.get_ticks_msec() < _last_unit_selected_timestamp + DOUBLE_CLICK_LB_MS:
		return
	if (
		unit == _last_unit_selected
		and Time.get_ticks_msec() <= _last_unit_selected_timestamp + DOUBLE_CLICK_UB_MS
	):
		_last_unit_selected = null
		_last_unit_selected_timestamp = 0
		_handle_double_click(unit.type)
	else:
		_last_unit_selected = unit
		_last_unit_selected_timestamp = Time.get_ticks_msec()

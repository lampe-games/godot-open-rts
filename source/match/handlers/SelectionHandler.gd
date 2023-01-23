extends Node3D

@export var rectangular_selection_3d: NodePath

var _rectangular_selection_3d = null
var _highlighted_units = Utils.Set.new()


func _ready():
	_rectangular_selection_3d = get_node_or_null(rectangular_selection_3d)
	if _rectangular_selection_3d == null:
		return
	_rectangular_selection_3d.started.connect(_on_selection_started)
	_rectangular_selection_3d.interrupted.connect(_on_selection_interrupted)
	_rectangular_selection_3d.finished.connect(_on_selection_finished)


func _force_highlight(units_to_highlight):
	for unit in units_to_highlight.iterate():
		var highlight = unit.find_child("Highlight")
		if highlight != null:
			highlight.force()


func _unforce_highlight(units_not_to_highlight_anymore):
	for unit in units_not_to_highlight_anymore.iterate():
		var highlight = unit.find_child("Highlight")
		if highlight != null:
			highlight.unforce()


func _get_controlled_units_within_topdown_polygon_2d(topdown_polygon_2d):
	if topdown_polygon_2d == null:
		return Utils.Set.new()
	var units_within_polygon = Utils.Set.new()
	for unit in get_tree().get_nodes_in_group("controlled_units"):
		if not unit.visible:
			continue
		var unit_position_2d = Vector2(unit.transform.origin.x, unit.transform.origin.z)
		if Geometry2D.is_point_in_polygon(unit_position_2d, topdown_polygon_2d):
			units_within_polygon.add(unit)
	return units_within_polygon


func _select_controlled_units_within_topdown_polygon_2d(topdown_polygon_2d):
	var units_to_select = _get_controlled_units_within_topdown_polygon_2d(topdown_polygon_2d)
	if not units_to_select.empty():
		MatchSignals.deselect_all_units.emit()
	for unit in units_to_select.iterate():
		var selection = unit.find_child("Selection")
		if selection != null:
			selection.select()


func _on_selection_started():
	_rectangular_selection_3d.changed.connect(_on_selection_changed)


func _on_selection_changed(topdown_polygon_2d):
	var units_to_highlight = _get_controlled_units_within_topdown_polygon_2d(topdown_polygon_2d)
	var units_not_to_highlight_anymore = Utils.Set.subtracted(
		_highlighted_units, units_to_highlight
	)
	_force_highlight(units_to_highlight)
	_unforce_highlight(units_not_to_highlight_anymore)
	_highlighted_units = units_to_highlight


func _on_selection_interrupted():
	_rectangular_selection_3d.changed.disconnect(_on_selection_changed)
	_unforce_highlight(_highlighted_units)
	_highlighted_units = Utils.Set.new()


func _on_selection_finished(topdown_polygon_2d):
	_rectangular_selection_3d.changed.disconnect(_on_selection_changed)
	_unforce_highlight(_highlighted_units)
	_highlighted_units = Utils.Set.new()
	_select_controlled_units_within_topdown_polygon_2d(topdown_polygon_2d)

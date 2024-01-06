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
		if unit == null:
			continue
		var highlight = unit.find_child("Highlight")
		if highlight != null:
			highlight.unforce()


func _get_controlled_units_from_navigation_domain_within_topdown_polygon_2d(
	navigation_domain, topdown_polygon_2d
):
	if topdown_polygon_2d == null:
		return Utils.Set.new()
	var units_within_polygon = Utils.Set.new()
	for unit in get_tree().get_nodes_in_group("controlled_units"):
		if not unit.visible or unit.movement_domain != navigation_domain:
			continue
		var unit_position_2d = Vector2(unit.transform.origin.x, unit.transform.origin.z)
		if Geometry2D.is_point_in_polygon(unit_position_2d, topdown_polygon_2d):
			units_within_polygon.add(unit)
	return units_within_polygon


func _rebase_topdown_polygon_2d_to_different_plane(topdown_polygon_2d, plane):
	var rebased_topdown_polygon_2d = []
	var camera = get_viewport().get_camera_3d()
	for polygon_point_2d in topdown_polygon_2d:
		var screen_point_2d = camera.unproject_position(
			Vector3(polygon_point_2d.x, Constants.Match.Terrain.PLANE.d, polygon_point_2d.y)
		)
		var rebased_point_3d = camera.get_ray_intersection_with_plane(screen_point_2d, plane)
		rebased_topdown_polygon_2d.append(Vector2(rebased_point_3d.x, rebased_point_3d.z))
	return rebased_topdown_polygon_2d


func _on_selection_started():
	_rectangular_selection_3d.changed.connect(_on_selection_changed)


func _on_selection_changed(topdown_polygon_2d):
	var units_to_highlight = _get_controlled_units_from_navigation_domain_within_topdown_polygon_2d(
		Constants.Match.Navigation.Domain.TERRAIN, topdown_polygon_2d
	)
	units_to_highlight.merge(
		_get_controlled_units_from_navigation_domain_within_topdown_polygon_2d(
			Constants.Match.Navigation.Domain.AIR,
			_rebase_topdown_polygon_2d_to_different_plane(
				topdown_polygon_2d, Constants.Match.Air.PLANE
			)
		)
	)
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
	var units_to_select = _get_controlled_units_from_navigation_domain_within_topdown_polygon_2d(
		Constants.Match.Navigation.Domain.TERRAIN, topdown_polygon_2d
	)
	units_to_select.merge(
		_get_controlled_units_from_navigation_domain_within_topdown_polygon_2d(
			Constants.Match.Navigation.Domain.AIR,
			_rebase_topdown_polygon_2d_to_different_plane(
				topdown_polygon_2d, Constants.Match.Air.PLANE
			)
		)
	)
	Utils.Match.select_units(units_to_select)

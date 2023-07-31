extends PanelContainer

const Unit = preload("res://source/match/units/Unit.gd")

const GROUND_LEVEL_PLANE = Plane(Vector3.UP, 0)
const MINIMAP_PIXELS_PER_WORLD_METER = 2
const RESOURCE_UNIT_REPRESENTATION_COLOR = Color.YELLOW

var _unit_to_corresponding_node_mapping = {}

@onready var _match = find_parent("Match")
@onready var _camera_indicator = find_child("CameraIndicator")
@onready var _viewport = find_child("MinimapViewport")
@onready var _viewport_background = find_child("Background")


func _ready():
	if not FeatureFlags.show_minimap:
		queue_free()
	_remove_dummy_nodes()
	await _match.ready  # make sure Match is ready as it may change map on setup
	find_child("MinimapViewport").size = (
		_match.find_child("Map").size * MINIMAP_PIXELS_PER_WORLD_METER
	)


func _physics_process(_delta):
	_sync_real_units_with_minimap_representations()
	_update_camera_indicator()


func _remove_dummy_nodes():
	for dummy_node in find_children("EditorOnlyDummy*"):
		dummy_node.queue_free()


func _sync_real_units_with_minimap_representations():
	var units_synced = {}
	var units_to_sync = (
		get_tree().get_nodes_in_group("units") + get_tree().get_nodes_in_group("resource_units")
	)
	for unit in units_to_sync:
		if not unit.visible:
			continue
		units_synced[unit] = 1
		if not _unit_is_mapped(unit):
			_map_unit(unit)
		_sync_unit(unit)
	for mapped_unit in _unit_to_corresponding_node_mapping:
		if not mapped_unit in units_synced:
			_cleanup_mapping(mapped_unit)


func _unit_is_mapped(unit):
	return unit in _unit_to_corresponding_node_mapping


func _map_unit(unit):
	var node_representing_unit = ColorRect.new()
	node_representing_unit.size = Vector2(3, 3)
	if not unit is Unit:
		node_representing_unit.rotation_degrees = 45
	_viewport_background.add_sibling(node_representing_unit)
	node_representing_unit.pivot_offset = node_representing_unit.size / 2.0
	_unit_to_corresponding_node_mapping[unit] = node_representing_unit


func _sync_unit(unit):
	var unit_pos_3d = unit.global_transform.origin
	var unit_pos_2d = Vector2(unit_pos_3d.x, unit_pos_3d.z) * MINIMAP_PIXELS_PER_WORLD_METER
	_unit_to_corresponding_node_mapping[unit].position = unit_pos_2d
	_unit_to_corresponding_node_mapping[unit].color = (
		unit.player.color if unit is Unit else RESOURCE_UNIT_REPRESENTATION_COLOR
	)


func _cleanup_mapping(unit):
	_unit_to_corresponding_node_mapping[unit].queue_free()
	_unit_to_corresponding_node_mapping.erase(unit)


func _update_camera_indicator():
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	var camera_corners = [
		Vector2.ZERO,
		Vector2(0, viewport.size.y),
		viewport.size,
		Vector2(viewport.size.x, 0),
		Vector2.ZERO
	]
	for index in range(camera_corners.size()):
		var corner_mapped_to_3d_position_on_ground_level = (
			GROUND_LEVEL_PLANE.intersects_ray(
				camera.project_ray_origin(camera_corners[index]),
				camera.project_ray_normal(camera_corners[index])
			)
			* MINIMAP_PIXELS_PER_WORLD_METER
		)
		_camera_indicator.set_point_position(
			index,
			Vector2(
				corner_mapped_to_3d_position_on_ground_level.x,
				corner_mapped_to_3d_position_on_ground_level.z
			)
		)

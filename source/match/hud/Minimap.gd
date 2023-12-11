extends PanelContainer

const Unit = preload("res://source/match/units/Unit.gd")
const Moving = preload("res://source/match/units/actions/Moving.gd")

const GROUND_LEVEL_PLANE = Plane(Vector3.UP, 0)
const MINIMAP_PIXELS_PER_WORLD_METER = 2

var _unit_to_corresponding_node_mapping = {}
var _camera_movement_active = false

@onready var _match = find_parent("Match")
@onready var _camera_indicator = find_child("CameraIndicator")
@onready var _viewport_background = find_child("Background")
@onready var _texture_rect = find_child("MinimapTextureRect")


func _ready():
	if not FeatureFlags.show_minimap:
		queue_free()
	_remove_dummy_nodes()
	await _match.ready  # make sure Match is ready as it may change map on setup
	find_child("MinimapViewport").size = (
		_match.find_child("Map").size * MINIMAP_PIXELS_PER_WORLD_METER
	)
	_texture_rect.gui_input.connect(_on_gui_input)


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
		unit.player.color if unit is Unit else unit.color
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


func _texture_rect_position_to_world_position(position_2d_within_texture_rect):
	assert(
		_texture_rect.stretch_mode == _texture_rect.STRETCH_KEEP_ASPECT_CENTERED,
		"world 3d position retrieval algorithm assumes 'STRETCH_KEEP_ASPECT_CENTERED'"
	)
	var texture_rect_size = _texture_rect.size
	var texture_size = _texture_rect.texture.get_size()
	var proportions = texture_rect_size / texture_size
	var scaling_factor = proportions.x if proportions.x < proportions.y else proportions.y
	var scaled_texture_size = texture_size * scaling_factor
	var scaled_texture_position_within_texture_rect = (
		(texture_rect_size - scaled_texture_size) / 2.0
	)
	var rect_containing_scaled_texture = Rect2(
		scaled_texture_position_within_texture_rect, scaled_texture_size
	)
	if rect_containing_scaled_texture.has_point(position_2d_within_texture_rect):
		var position_2d_within_minimap = (
			(position_2d_within_texture_rect - rect_containing_scaled_texture.position)
			/ scaling_factor
		)
		return position_2d_within_minimap / MINIMAP_PIXELS_PER_WORLD_METER
	return null


func _try_teleporting_camera_based_on_local_texture_rect_position(position_2d_within_texture_rect):
	var world_position_2d = _texture_rect_position_to_world_position(
		position_2d_within_texture_rect
	)
	if world_position_2d == null:
		return
	var world_position_3d = Vector3(world_position_2d.x, 0, world_position_2d.y)
	get_viewport().get_camera_3d().set_position_safely(world_position_3d)


func _issue_movement_action(position_2d_within_texture_rect):
	var world_position_2d = _texture_rect_position_to_world_position(
		position_2d_within_texture_rect
	)
	if world_position_2d == null:
		return
	var abstract_world_position_3d = Vector3(world_position_2d.x, 0, world_position_2d.y)
	var camera = get_viewport().get_camera_3d()
	var target_point_on_colliding_surface = camera.get_ray_intersection(
		camera.unproject_position(abstract_world_position_3d)
	)
	MatchSignals.terrain_targeted.emit(target_point_on_colliding_surface)


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			_try_teleporting_camera_based_on_local_texture_rect_position(event.position)
			_camera_movement_active = true
		if not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			_camera_movement_active = false
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			_issue_movement_action(event.position)
	elif event is InputEventMouseMotion and _camera_movement_active:
		_try_teleporting_camera_based_on_local_texture_rect_position(event.position)

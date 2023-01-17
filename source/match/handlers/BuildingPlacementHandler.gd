extends Node3D

enum BlueprintPositionValidity {
	VALID,
	COLLIDES_WITH_OBJECT,
	COLLIDES_WITH_TERRAIN,
	NOT_ENOUGH_RESOURCES,
}

const ROTATION_BY_KEY_STEP = 45.0
const ROTATION_DEAD_ZONE_DISTANCE = 0.1

const MATERIALS_ROOT = "res://source/match/resources/materials/"
const BLUEPRINT_VALID_PATH = MATERIALS_ROOT + "blueprint_valid.material.tres"
const BLUEPRINT_INVALID_PATH = MATERIALS_ROOT + "blueprint_invalid.material.tres"

var _active_blueprint_node = null
var _pending_building_prototype = null
var _blueprint_rotating = false

@onready var _match = find_parent("Match")
@onready var _feedback_label = find_child("FeedbackLabel3D")


func _ready():
	_feedback_label.hide()
	MatchSignals.place_building.connect(_on_building_placement_request)


func _unhandled_input(event):
	if not _building_placement_started():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_lmb_down_event(event)
	if event.is_action_pressed("rotate_building"):
		_try_rotating_blueprint_by(ROTATION_BY_KEY_STEP)
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		_handle_lmb_up_event(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_handle_rmb_event(event)
	if event is InputEventMouseMotion:
		_handle_mouse_motion_event(event)


func _handle_lmb_down_event(_event):
	get_viewport().set_input_as_handled()
	_start_blueprint_rotation()


func _handle_lmb_up_event(_event):
	get_viewport().set_input_as_handled()
	if _blueprint_position_is_valid():
		_finish_building_placement()
	_finish_blueprint_rotation()


func _handle_rmb_event(event):
	get_viewport().set_input_as_handled()
	if event.pressed:
		_finish_blueprint_rotation()
		_cancel_building_placement()


func _handle_mouse_motion_event(_event):
	get_viewport().set_input_as_handled()
	if _blueprint_rotation_started():
		_rotate_blueprint_towards_mouse_pos()
	else:
		_set_blueprint_position_based_on_mouse_pos()
	var blueprint_position_validity = _calculate_blueprint_position_validity()
	_update_feedback_label(blueprint_position_validity)
	_update_blueprint_color(blueprint_position_validity == BlueprintPositionValidity.VALID)


func _building_placement_started():
	return _active_blueprint_node != null


func _blueprint_position_is_valid():
	return _calculate_blueprint_position_validity() == BlueprintPositionValidity.VALID


func _blueprint_rotation_started():
	return _blueprint_rotating == true


func _calculate_blueprint_position_validity():
	if not _player_has_enough_resources():
		return BlueprintPositionValidity.NOT_ENOUGH_RESOURCES
	if _active_bluprint_collides_with_terrain():
		return BlueprintPositionValidity.COLLIDES_WITH_TERRAIN
	if _active_bluprint_collides_with_object():
		return BlueprintPositionValidity.COLLIDES_WITH_OBJECT
	return BlueprintPositionValidity.VALID


func _player_has_enough_resources():
	var construction_cost = Constants.Match.Units.CONSTRUCTION_COSTS[
		_pending_building_prototype . resource_path
	]
	return _match.players[_match.controlled_player_id].has_resources(construction_cost)


func _active_bluprint_collides_with_terrain():
	return (
		_active_blueprint_node != null
		and _active_blueprint_node.get_overlapping_areas().is_empty()
		and _active_blueprint_node.get_overlapping_bodies().size() == 1
		and _active_blueprint_node.get_overlapping_bodies()[0].collision_layer == 1
	)


func _active_bluprint_collides_with_object():
	return (
		_active_blueprint_node != null
		and (
			not _active_blueprint_node.get_overlapping_areas().is_empty()
			or not _active_blueprint_node.get_overlapping_bodies().is_empty()
		)
	)


func _update_feedback_label(blueprint_position_validity):
	_feedback_label.visible = (blueprint_position_validity != BlueprintPositionValidity.VALID)
	# TODO: use translations
	match blueprint_position_validity:
		BlueprintPositionValidity.COLLIDES_WITH_OBJECT:
			_feedback_label.text = "Something already ocuppies that spot"
		BlueprintPositionValidity.COLLIDES_WITH_TERRAIN:
			_feedback_label.text = "Irregular terrain"
		BlueprintPositionValidity.NOT_ENOUGH_RESOURCES:
			_feedback_label.text = "Not enough resources"


func _start_building_placement(building_prototype):
	if _building_placement_started():
		return
	_pending_building_prototype = building_prototype
	_active_blueprint_node = (
		load(Constants.Match.Units.BUILDING_BLUEPRINTS[building_prototype.resource_path])
		. instantiate()
	)
	var blueprint_origin = Vector3(-999, 0, -999)
	var camera_direction_yless = (
		(get_viewport().get_camera_3d().project_ray_normal(Vector2(0, 0)) * Vector3(1, 0, 1))
		. normalized()
	)
	var rotate_towards = blueprint_origin + camera_direction_yless.rotated(Vector3.UP, PI * 0.75)
	_active_blueprint_node.global_transform = Transform3D(Basis(), blueprint_origin).looking_at(
		rotate_towards, Vector3.UP
	)
	add_child(_active_blueprint_node)


func _set_blueprint_position_based_on_mouse_pos():
	var mouse_pos_2d = get_viewport().get_mouse_position()
	var mouse_pos_3d = get_viewport().get_camera_3d().get_ray_intersection(mouse_pos_2d)
	if mouse_pos_3d == null:
		return
	_active_blueprint_node.global_transform.origin = mouse_pos_3d
	_feedback_label.global_transform.origin = mouse_pos_3d


func _update_blueprint_color(blueprint_position_is_valid):
	var material_to_set = (
		preload(BLUEPRINT_VALID_PATH)
		if blueprint_position_is_valid
		else preload(BLUEPRINT_INVALID_PATH)
	)
	for child in _active_blueprint_node.get_children():
		if "material_override" in child:
			child.material_override = material_to_set


func _cancel_building_placement():
	if _building_placement_started():
		_feedback_label.hide()
		_active_blueprint_node.queue_free()
		_active_blueprint_node = null


func _finish_building_placement():
	if _player_has_enough_resources():
		var construction_cost = Constants.Match.Units.CONSTRUCTION_COSTS[
			_pending_building_prototype . resource_path
		]
		_match.players[_match.controlled_player_id].subtract_resources(construction_cost)
		MatchSignals.setup_and_spawn_unit.emit(
			_pending_building_prototype.instantiate(),
			_active_blueprint_node.global_transform,
			_match.controlled_player_id
		)
	_cancel_building_placement()


func _start_blueprint_rotation():
	_blueprint_rotating = true


func _try_rotating_blueprint_by(degrees):
	if not _building_placement_started():
		return
	_active_blueprint_node.global_transform.basis = (
		_active_blueprint_node . global_transform . basis . rotated(Vector3.UP, deg_to_rad(degrees))
	)


func _rotate_blueprint_towards_mouse_pos():
	var mouse_pos_2d = get_viewport().get_mouse_position()
	var mouse_pos_3d = get_viewport().get_camera_3d().get_ray_intersection(mouse_pos_2d)
	if mouse_pos_3d == null:
		return
	var mouse_pos_yless = mouse_pos_3d * Vector3(1, 0, 1)
	var blueprint_pos_3d = _active_blueprint_node.global_transform.origin
	var blueprint_pos_yless = blueprint_pos_3d * Vector3(-999, 0, -999)
	if mouse_pos_yless.distance_to(blueprint_pos_yless) < ROTATION_DEAD_ZONE_DISTANCE:
		return
	_active_blueprint_node.global_transform = _active_blueprint_node.global_transform.looking_at(
		Vector3(mouse_pos_yless.x, blueprint_pos_3d.y, mouse_pos_yless.z), Vector3.UP
	)


func _finish_blueprint_rotation():
	_blueprint_rotating = false


func _on_building_placement_request(building_prototype):
	_start_building_placement(building_prototype)

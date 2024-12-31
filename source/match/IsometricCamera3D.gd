extends Camera3D

const EXPECTED_X_ROTATION_DEGREES = -30.0
const EXPECTED_PROJECTION = PROJECTION_ORTHOGONAL

@export_group("Size")
@export var size_min = 1
@export var size_max = 20
@export_group("Movement")
@export var screen_margin_for_movement = 2  # px
@export var movement_speed = 1.1
@export var bounding_planes: Array[Plane] = []
@export_group("Rotation")
@export var mouse_rotation_speed = 0.005  # [rad/px]
@export var arrowkey_rotation_speed = 2  # [rad/s]
@export var default_y_rotation_degrees = 0.0
@export var reference_plane_for_rotation = Plane(Vector3.UP, 0.0)
@export_group("View")
@export var visible_height_min = -10
@export var visible_height_max = 10

var _mouse_pos_when_rotation_started = null
var _camera_global_pos_when_rotation_started = null


func _ready():
	assert(projection == EXPECTED_PROJECTION, "unexpected projection")
	assert(
		is_equal_approx(rotation_degrees.x, EXPECTED_X_ROTATION_DEGREES), "unexptected X rotation"
	)
	_align_camera_properties_to_current_size()


func _physics_process(delta: float):
	var realtime_delta = delta / Engine.time_scale
	if _try_handling_movement(realtime_delta):
		return
	_try_handling_arrowkey_rotation(realtime_delta)


func _unhandled_input(event: InputEvent):
	_try_handling_zoom(event)
	_try_handling_mouse_rotation(event)


func set_size_safely(a_size: float):
	if a_size == size:
		return
	size = clamp(a_size, size_min, size_max)
	_align_camera_properties_to_current_size()


func set_position_safely(target_position: Vector3):
	global_transform.origin = _target_position_to_camera_position(target_position)


func get_ray_intersection(mouse_pos: Vector2) -> Variant:
	return get_ray_intersection_with_plane(mouse_pos, reference_plane_for_rotation)


func get_ray_intersection_with_plane(mouse_pos: Vector2, plane: Plane) -> Variant:
	return plane.intersects_ray(project_ray_origin(mouse_pos), project_ray_normal(mouse_pos))


func _try_handling_movement(delta: float) -> bool:
	if _is_rotating():
		return false

	var screen_move_vector = _calculate_screen_move_vector()
	if screen_move_vector.is_zero_approx():
		return false

	var scaled_screen_move_vector = (
		screen_move_vector.normalized()
		* delta
		* Vector2(movement_speed, movement_speed * 2.0)
		* size
	)
	var camera_move_vector = (
		Vector3(scaled_screen_move_vector.x, 0, scaled_screen_move_vector.y)
		. rotated(Vector3(0, 1, 0), rotation.y)
	)
	global_translate(camera_move_vector)
	_align_position_to_bounding_planes()
	return true


func _calculate_screen_move_vector() -> Vector2:
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()

	var x_axis = Input.get_axis("move_map_left", "move_map_right")
	var y_axis = Input.get_axis("move_map_up", "move_map_down")
	var move_vector = Vector2(x_axis, y_axis)

	if mouse_pos.x <= screen_margin_for_movement:
		move_vector.x = -1

	if mouse_pos.x >= viewport_size.x - screen_margin_for_movement:
		move_vector.x = 1

	if mouse_pos.y <= screen_margin_for_movement:
		move_vector.y = -1

	if mouse_pos.y >= viewport_size.y - screen_margin_for_movement:
		move_vector.y = 1

	return move_vector


func _try_handling_zoom(event: InputEvent):
	if not event is InputEventMouseButton or not event.is_pressed():
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_in()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_out()


func _zoom_in():
	set_size_safely(size - 1)


func _zoom_out():
	set_size_safely(size + 1)


func _try_handling_arrowkey_rotation(delta: float):
	if _is_rotating():
		return
	var angle_radians = (
		delta
		* Input.get_axis("rotate_map_counterclockwise", "rotate_map_clockwise")
		* arrowkey_rotation_speed
	)
	if not is_zero_approx(angle_radians):
		_rotate_from_reference_position_by(global_position, angle_radians)


func _try_handling_mouse_rotation(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE and event.double_click:
			_reset_rotation()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE:
			_start_rotation(event)
		elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE:
			_stop_rotation()
	elif event is InputEventMouseMotion and _is_rotating():
		var mouse_pos = event.position
		var angle_radians = (
			(mouse_pos.x - _mouse_pos_when_rotation_started.x) * mouse_rotation_speed
		)
		_rotate_from_reference_position_by(_camera_global_pos_when_rotation_started, angle_radians)


func _reset_rotation():
	var pivot_point = _calculate_pivot_point()
	if pivot_point == null:
		return
	var camera_position = global_position
	var camera_position_yless = camera_position * Vector3(1, 0, 1)
	var pivot_point_yless = pivot_point * Vector3(1, 0, 1)
	var pivot_to_camera_distance_yless = camera_position_yless.distance_to(pivot_point_yless)
	var new_camera_position_yless = (
		pivot_point_yless
		- (
			Vector3(0, 0, -1).normalized().rotated(
				-Vector3.UP, deg_to_rad(-default_y_rotation_degrees)
			)
			* pivot_to_camera_distance_yless
		)
	)
	global_position = Vector3(
		new_camera_position_yless.x, camera_position.y, new_camera_position_yless.z
	)
	global_transform = global_transform.looking_at(pivot_point, Vector3(0, 1, 0))


func _start_rotation(event: InputEvent):
	_mouse_pos_when_rotation_started = event.position
	_camera_global_pos_when_rotation_started = global_transform.origin


func _stop_rotation():
	_mouse_pos_when_rotation_started = null


func _rotate_from_reference_position_by(reference_position: Vector3, angle_radians: float):
	var pivot_point = _calculate_pivot_point()
	if pivot_point == null:
		return
	var diff_vec = reference_position - pivot_point
	var rotated_diff_vec = diff_vec.rotated(-Vector3.UP, angle_radians)
	var rotated_reference_position = pivot_point + rotated_diff_vec
	global_position = rotated_reference_position
	global_transform = global_transform.looking_at(pivot_point, Vector3.UP)


func _is_rotating() -> bool:
	return _mouse_pos_when_rotation_started != null


func _calculate_pivot_point() -> Vector3:
	var screen_center_pos_2d = get_viewport().size / 2.0
	return get_ray_intersection_with_plane(screen_center_pos_2d, reference_plane_for_rotation)


func _align_camera_properties_to_current_size():
	_align_camera_properties_to_size(size)


func _align_camera_properties_to_size(a_size: float):
	_align_camera_position_to_size(a_size)
	_align_camera_far_to_size(a_size)


func _align_camera_position_to_size(a_size: float):
	var alpha_degrees = 60
	var beta_degrees = 90 - alpha_degrees
	var target_height = (
		a_size * sin(deg_to_rad(alpha_degrees)) / 2.0
		+ sin(deg_to_rad(beta_degrees))
		+ visible_height_max
	)
	var target_camera_plane = Plane(Vector3.UP, target_height)
	var camera_ray_normal = project_ray_normal(Vector2(0, 0))
	var target_camera_pos = target_camera_plane.intersects_ray(
		global_transform.origin, camera_ray_normal
	)
	if target_camera_pos == null:
		target_camera_pos = target_camera_plane.intersects_ray(
			global_transform.origin, -camera_ray_normal
		)
	global_transform.origin = target_camera_pos


func _align_camera_far_to_size(a_size: float):
	var up = (project_position(Vector2(0, 0), 0) - project_position(Vector2(0, 1), 0)).normalized()
	var camera_ray_begin = project_position(Vector2(0, 0), 0) + up * (a_size - size) / 2.0
	var camera_ray_normal = project_ray_normal(Vector2(0, 0))
	var min_visible_plane = Plane(Vector3.UP, visible_height_min)
	var ray_intersection = min_visible_plane.intersects_ray(camera_ray_begin, camera_ray_normal)
	far = ceil(ray_intersection.distance_to(camera_ray_begin))


func _align_position_to_bounding_planes():
	var pivot_point = _calculate_pivot_point()
	var aligned_pivot_point = _clamp_position_to_bounding_planes(pivot_point)
	var diff = aligned_pivot_point - pivot_point
	global_transform.origin += diff


func _clamp_position_to_bounding_planes(a_position: Vector3) -> Vector3:
	for bounding_plane in bounding_planes:
		if not bounding_plane.is_point_over(a_position):
			a_position = a_position - bounding_plane.normal * bounding_plane.distance_to(a_position)
	return a_position


func _target_position_to_camera_position(target_position: Vector3) -> Vector3:
	target_position = _clamp_position_to_bounding_planes(target_position)
	var screen_center_pos_2d = get_viewport().size / 2.0
	var camera_ray = project_ray_normal(screen_center_pos_2d)
	var target_plane = Plane(Vector3.UP, target_position.y)
	var intersection = target_plane.intersects_ray(global_transform.origin, camera_ray)
	var offset_yless = (target_position - intersection) * Vector3(1, 0, 1)
	return global_transform.origin + offset_yless

extends Camera3D

# TODO: perform rotation calculations in 3D space

const EXPECTED_X_ROTATION_DEGREES = -30.0
const EXPECTED_PROJECTION = PROJECTION_ORTHOGONAL

@export_group("Size")
@export var size_min = 1
@export var size_max = 20
@export_group("Movement")
@export var screen_margin_for_movement = 2
@export var movement_speed = 1.1
@export var bounding_planes: Array[Plane] = []
@export_group("Rotation")
@export var rotation_speed = 0.005
@export var arrowkey_rotation_speed = 200
@export var default_y_rotation_degrees = 0.0
@export var reference_plane_for_rotation = Plane(Vector3.UP, 0.0)
@export_group("View")
@export var visible_height_min = -10
@export var visible_height_max = 10

var _movement_vector_2d = Vector2(0, 0)
var _pivot_point_2d = null
var _pivot_point_3d = null
var _camera_point_3d = null
var _rotation_pos = Vector2.ZERO
var _arrowkey_rotation = false

func _ready():
	assert(projection == EXPECTED_PROJECTION, "unexpected projection")
	assert(
		is_equal_approx(rotation_degrees.x, EXPECTED_X_ROTATION_DEGREES), "unexptected X rotation"
	)
	_align_camera_properties_to_current_size()


func _physics_process(delta):
	if _movement_vector_2d != Vector2(0, 0):
		var real_delta = delta / Engine.time_scale
		var scaled_movement_vector_2d = (
			_movement_vector_2d.normalized()
			* real_delta
			* Vector2(movement_speed, movement_speed * 2.0)
			* size
		)
		var movement_vector_3d = Vector3(
			scaled_movement_vector_2d.x, 0, scaled_movement_vector_2d.y
		)
		movement_vector_3d = movement_vector_3d.rotated(Vector3(0, 1, 0), rotation.y)
		global_translate(movement_vector_3d)
		_align_position_to_bounding_planes()


func _process(_delta):
	if !_is_rotating():
		_move()
	elif _arrowkey_rotation:
		if (Input.is_action_pressed("rotate_map_clock")):
			_rotation_pos.x += _delta * arrowkey_rotation_speed
		if (Input.is_action_pressed("rotate_map_counterclock")):
			_rotation_pos.x -= _delta * arrowkey_rotation_speed
		_rotate(_rotation_pos)


func _unhandled_input(event):
	if !_is_rotating():
		if Input.is_action_just_pressed("rotate_map_clock") or Input.is_action_just_pressed("rotate_map_counterclock"):
			_arrowkey_rotation = true
			_start_rotation(event)
	else:
		if Input.is_action_just_released("rotate_map_clock") or Input.is_action_just_released("rotate_map_counterclock")  :
			if not (Input.is_action_pressed("rotate_map_clock") or Input.is_action_pressed("rotate_map_counterclock")):
				_arrowkey_rotation = false
				_stop_rotation()
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()
		elif (
			event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE and event.double_click
		):
			_reset_rotation()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE and !_arrowkey_rotation:
			_start_rotation(event)
		elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE and !_arrowkey_rotation:
			_stop_rotation()
	elif event is InputEventMouseMotion:
		var rotation_pos = event.position #the mouse position
		if !_arrowkey_rotation and _is_rotating():
			_rotate(rotation_pos)


func set_size_safely(a_size):
	if a_size == size:
		return
	size = clamp(a_size, size_min, size_max)
	_align_camera_properties_to_current_size()


func set_position_safely(target_position: Vector3):
	global_transform.origin = _target_position_to_camera_position(target_position)


func get_ray_intersection(mouse_pos):
	return get_ray_intersection_with_plane(mouse_pos, reference_plane_for_rotation)


func get_ray_intersection_with_plane(mouse_pos, plane):
	return plane.intersects_ray(project_ray_origin(mouse_pos), project_ray_normal(mouse_pos))


func _zoom_in():
	set_size_safely(size - 1)


func _zoom_out():
	set_size_safely(size + 1)


func _reset_rotation():
	var pivot_point_3d = _calculate_pivot_point_3d()
	if pivot_point_3d == null:
		return
	var camera_point_3d = global_transform.origin
	var camera_point_2d = Vector2(camera_point_3d.x, camera_point_3d.z)
	var pivot_point_2d = Vector2(pivot_point_3d.x, pivot_point_3d.z)
	var pivot_to_camera_distance_2d = camera_point_2d.distance_to(pivot_point_2d)
	var new_camera_point_2d = (
		pivot_point_2d
		- (
			Vector2(0.0, -1.0).normalized().rotated(deg_to_rad(-default_y_rotation_degrees))
			* pivot_to_camera_distance_2d
		)
	)
	global_transform.origin = Vector3(
		new_camera_point_2d.x, camera_point_3d.y, new_camera_point_2d.y
	)
	global_transform = global_transform.looking_at(pivot_point_3d, Vector3(0, 1, 0))


func _start_rotation(event):
	_pivot_point_3d = _calculate_pivot_point_3d()
	if _pivot_point_3d != null:
		_movement_vector_2d = Vector2(0, 0)
		if "position" in event:
			_pivot_point_2d = event.position
		else:
			_pivot_point_2d = Vector2.ZERO
		_camera_point_3d = global_transform.origin


func _stop_rotation():
	_pivot_point_2d = null
	_rotation_pos = Vector2.ZERO


func _rotate(rotation_pos):
	var strength = rotation_pos.x - _pivot_point_2d.x
	var camera_point_2d = Vector2(_camera_point_3d.x, _camera_point_3d.z)
	var pivot_point_2d = Vector2(_pivot_point_3d.x, _pivot_point_3d.z)
	var diff_vec = camera_point_2d - pivot_point_2d
	var rotated_diff_vec = diff_vec.rotated(strength * rotation_speed)
	var new_camera_point_2d = pivot_point_2d + rotated_diff_vec
	global_transform.origin = Vector3(
		new_camera_point_2d.x, _camera_point_3d.y, new_camera_point_2d.y
	)
	global_transform = global_transform.looking_at(_pivot_point_3d, Vector3(0, 1, 0))


func _move():
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()

	var x_axis = Input.get_axis("move_map_left", "move_map_right")
	var y_axis = Input.get_axis("move_map_up", "move_map_down")
	_movement_vector_2d = Vector2(x_axis, y_axis)

	if mouse_pos.x <= screen_margin_for_movement:
		_movement_vector_2d.x = -1

	if mouse_pos.x >= viewport_size.x - screen_margin_for_movement:
		_movement_vector_2d.x = 1

	if mouse_pos.y <= screen_margin_for_movement:
		_movement_vector_2d.y = -1

	if mouse_pos.y >= viewport_size.y - screen_margin_for_movement:
		_movement_vector_2d.y = 1


func _is_rotating():
	return _pivot_point_2d != null


func _calculate_pivot_point_3d():
	var screen_center_pos_2d = get_viewport().size / 2.0
	return get_ray_intersection_with_plane(screen_center_pos_2d, reference_plane_for_rotation)


func _align_camera_properties_to_current_size():
	_align_camera_properties_to_size(size)


func _align_camera_properties_to_size(a_size):
	_align_camera_position_to_size(a_size)
	_align_camera_far_to_size(a_size)


func _align_camera_position_to_size(a_size):
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


func _align_camera_far_to_size(a_size):
	var up = (project_position(Vector2(0, 0), 0) - project_position(Vector2(0, 1), 0)).normalized()
	var camera_ray_begin = project_position(Vector2(0, 0), 0) + up * (a_size - size) / 2.0
	var camera_ray_normal = project_ray_normal(Vector2(0, 0))
	var min_visible_plane = Plane(Vector3.UP, visible_height_min)
	var ray_intersection = min_visible_plane.intersects_ray(camera_ray_begin, camera_ray_normal)
	far = ceil(ray_intersection.distance_to(camera_ray_begin))


func _align_position_to_bounding_planes():
	var pivot_point = _calculate_pivot_point_3d()
	var aligned_pivot_point = _clamp_position_to_bounding_planes(pivot_point)
	var diff = aligned_pivot_point - pivot_point
	global_transform.origin += diff


func _clamp_position_to_bounding_planes(a_position):
	for bounding_plane in bounding_planes:
		if not bounding_plane.is_point_over(a_position):
			a_position = a_position - bounding_plane.normal * bounding_plane.distance_to(a_position)
	return a_position


func _target_position_to_camera_position(target_position: Vector3):
	target_position = _clamp_position_to_bounding_planes(target_position)
	var screen_center_pos_2d = get_viewport().size / 2.0
	var camera_ray = project_ray_normal(screen_center_pos_2d)
	var target_plane = Plane(Vector3.UP, target_position.y)
	var intersection = target_plane.intersects_ray(global_transform.origin, camera_ray)
	var offset_yless = (target_position - intersection) * Vector3(1, 0, 1)
	return global_transform.origin + offset_yless

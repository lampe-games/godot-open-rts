extends Camera3D

const EXPECTED_X_ROTATION_DEGREES = -30.0
const EXPECTED_PROJECTION = PROJECTION_ORTHOGONAL

@export var size_min = 1
@export var size_max = 20
@export var screen_margin_for_movement = 1
@export var movement_speed = 1.1

var _movement_vector_2d = Vector2(0, 0)


func _ready():
	assert(projection == EXPECTED_PROJECTION)
	assert(is_equal_approx(rotation_degrees.x, EXPECTED_X_ROTATION_DEGREES))


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


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()
	elif event is InputEventMouseMotion:
		_move(event.position)


func _move(mouse_pos):
	var viewport_size = get_viewport().size
	_movement_vector_2d = Vector2(
		(
			-1 * int(mouse_pos.x <= screen_margin_for_movement)
			+ 1 * int(mouse_pos.x >= viewport_size.x - screen_margin_for_movement)
		),
		(
			-1 * int(mouse_pos.y <= screen_margin_for_movement)
			+ 1 * int(mouse_pos.y >= viewport_size.y - screen_margin_for_movement)
		)
	)


func _zoom_in():
	set_size_safely(size - 1)


func _zoom_out():
	set_size_safely(size + 1)


func set_size_safely(a_size):
	if a_size == size:
		return
	size = clamp(a_size, size_min, size_max)
	# TODO: align_camera_properties_to_current_size()

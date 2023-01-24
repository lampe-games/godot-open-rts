extends Node3D

signal started
signal changed(topdown_polygon_2d)
signal interrupted
signal finished(topdown_polygon_2d)

@export var polygon_plane = Plane(Vector3.UP, 0)
@export var interrupt_on_hitting_screen_margin = true
@export var screen_margin = 1
@export var changed_signal_interval_lower_bound = 1.0 / 60.0 * 5.0  # s

var _rect_on_screen = null
var _time_since_last_update = 0.0  # s


func _physics_process(delta):
	_throttle_update(delta)
	if _screen_margin_hit():
		_interrupt()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start()
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		_finish()


func _selecting():
	return _rect_on_screen != null


func _screen_margin_hit():
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()
	return (
		mouse_pos.x <= screen_margin
		or mouse_pos.x >= viewport_size.x - screen_margin
		or mouse_pos.y <= screen_margin
		or mouse_pos.y >= viewport_size.y - screen_margin
	)


func _start():
	var mouse_pos = get_viewport().get_mouse_position()
	_rect_on_screen = Rect2(0, 0, 0, 0)
	_rect_on_screen.position = mouse_pos
	started.emit()


func _interrupt():
	if not _selecting():
		return
	_rect_on_screen = null
	interrupted.emit()


func _finish():
	if not _selecting():
		return
	_rect_on_screen.end = get_viewport().get_mouse_position()
	finished.emit(_screen_rect_2d_to_topdown_polygon_2d(_rect_on_screen.abs()))
	_rect_on_screen = null


func _throttle_update(delta):
	if not _selecting():
		_time_since_last_update = 0.0
		return
	_time_since_last_update += delta
	if _time_since_last_update >= changed_signal_interval_lower_bound:
		_time_since_last_update = 0.0
		_update()


func _update():
	if not _selecting():
		return
	_rect_on_screen.end = get_viewport().get_mouse_position()
	changed.emit(_screen_rect_2d_to_topdown_polygon_2d(_rect_on_screen.abs()))


func _screen_rect_2d_to_topdown_polygon_2d(rect_2d):
	if rect_2d == null:
		return null
	var rect_points_2d = [
		rect_2d.position,
		Vector2(rect_2d.position.x, rect_2d.end.y),
		rect_2d.end,
		Vector2(rect_2d.end.x, rect_2d.position.y),
	]
	var polygon_points_2d = []
	for rect_point_2d in rect_points_2d:
		var polygon_point_3d = get_viewport().get_camera_3d().get_ray_intersection_with_plane(
			rect_point_2d, polygon_plane
		)
		polygon_points_2d.append(Vector2(polygon_point_3d.x, polygon_point_3d.z))
	return polygon_points_2d

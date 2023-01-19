extends Panel

signal finished(rect)

@export var interrupt_on_hitting_screen_margin = true
@export var screen_margin = 1

var _rect = null


func _ready():
	hide()


func _physics_process(_delta):
	_update()
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
	return _rect != null


func _screen_margin_hit():
	var viewport_size = get_viewport().size
	var mouse_pos = get_global_mouse_position()
	return (
		mouse_pos.x <= screen_margin
		or mouse_pos.x >= viewport_size.x - screen_margin
		or mouse_pos.y <= screen_margin
		or mouse_pos.y >= viewport_size.y - screen_margin
	)


func _start():
	var mouse_pos = get_global_mouse_position()
	_rect = Rect2(0, 0, 0, 0)
	_rect.position = mouse_pos


func _interrupt():
	_rect = null
	hide()


func _finish():
	if not _selecting():
		return
	_rect.end = get_global_mouse_position()
	finished.emit(_rect.abs())
	_rect = null
	hide()


func _update():
	if not _selecting():
		return
	_rect.end = get_global_mouse_position()
	var absolute_rect = _rect.abs()
	if absolute_rect.has_area():
		show()
	position = absolute_rect.position
	size = absolute_rect.size

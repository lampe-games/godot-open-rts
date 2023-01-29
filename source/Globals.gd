extends Node

const Options = preload("res://source/model/Options.gd")

var options = (
	load(Constants.OPTIONS_FILE_PATH)
	if ResourceLoader.exists(Constants.OPTIONS_FILE_PATH)
	else Options.new()
)
var god_mode = false


func _unhandled_input(event):
	if event.is_action_pressed("god_mode_toggle"):
		_toggle_god_mode()


func _toggle_god_mode():
	god_mode = not god_mode
	if god_mode:
		Signals.god_mode_enabled.emit()
	else:
		Signals.god_mode_disabled.emit()

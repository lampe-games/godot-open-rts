extends Control

@onready var _screen = find_child("Screen")
@onready var _mouse_movement_restricted = find_child("MouseMovementRestricted")


func _ready():
	_mouse_movement_restricted.button_pressed = Globals.options.mouse_restricted
	_screen.selected = Globals.options.screen


func _on_mouse_movement_restricted_pressed():
	Globals.options.mouse_restricted = _mouse_movement_restricted.button_pressed
	ResourceSaver.save(Globals.options, Constants.OPTIONS_FILE_PATH)


func _on_screen_item_selected(index):
	Globals.options.screen = {
		0: Globals.options.Screen.FULL,
		1: Globals.options.Screen.WINDOW,
	}[index]
	ResourceSaver.save(Globals.options, Constants.OPTIONS_FILE_PATH)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://source/main-menu/Main.tscn")

extends Node

const Options = preload("res://source/model/Options.gd")

var options = (
	load(Constants.OPTIONS_FILE_PATH)
	if ResourceLoader.exists(Constants.OPTIONS_FILE_PATH)
	else Options.new()
)

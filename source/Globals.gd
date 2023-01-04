extends Node

const Options = preload("res://source/model/Options.gd")

var options = (
	load("user://options.tres") if ResourceLoader.exists("user://options.tres") else Options.new()
)

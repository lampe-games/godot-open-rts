extends Control

var match_settings = null
var map_path = null

@onready var _label = find_child("Label")
@onready var _progress_bar = find_child("ProgressBar")


func _ready():
	_progress_bar.value = 0.0

	_label.text = tr("LOADING_STEP_PRELOADING")
	await get_tree().physics_frame
	_preload_scenes()
	_progress_bar.value = 0.2

	_label.text = tr("LOADING_STEP_LOADING_MAP")
	await get_tree().physics_frame
	var map = load(map_path).instantiate()
	_progress_bar.value = 0.4

	_label.text = tr("LOADING_STEP_LOADING_MATCH")
	await get_tree().physics_frame
	var match_prototype = load("res://source/match/Match.tscn")
	_progress_bar.value = 0.7

	_label.text = tr("LOADING_STEP_INSTANTIATING_MATCH")
	await get_tree().physics_frame
	var a_match = match_prototype.instantiate()
	a_match.settings = match_settings
	a_match.map = map
	_progress_bar.value = 0.9

	_label.text = tr("LOADING_STEP_STARTING_MATCH")
	await get_tree().physics_frame
	get_parent().add_child(a_match)
	get_tree().current_scene = a_match
	queue_free()


func _preload_scenes():
	var scene_paths = []
	scene_paths += Constants.Match.Units.PROJECTILES.values()
	scene_paths += Constants.Match.Units.CONSTRUCTION_COSTS.keys()
	for scene_path in scene_paths:
		Globals.cache[scene_path] = load(scene_path)

extends Node
var _active = false


func _ready():
	if not FeatureFlags.frame_incrementer:
		queue_free()


func _unhandled_input(event):
	if (
		event.is_action_pressed("toggle_frame_incrementer")
		and ((not _active and not get_tree().paused) or (_active and get_tree().paused))
	):
		_toggle()
	elif event.is_action_pressed("frame_incrementer_step"):
		get_tree().paused = false
		print("Frame incrementer un-paused at frame #", get_tree().get_frame())


func _process(_delta):
	if _active and not get_tree().paused:
		get_tree().paused = true
		print("Frame incrementer paused at frame #", get_tree().get_frame())


func _toggle():
	_active = not _active
	if not _active:
		get_tree().paused = false
		print("Frame incrementer un-paused at frame #", get_tree().get_frame())
	else:
		get_tree().paused = true
		print("Frame incrementer paused at frame #", get_tree().get_frame())

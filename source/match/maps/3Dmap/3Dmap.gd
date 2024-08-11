extends "res://source/match/Map.gd"

@onready var terrain = find_child("Terrain3D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		var target_point = get_viewport().get_camera_3d().get_ray_intersection(event.position)
		MatchSignals.terrain_targeted.emit(target_point)

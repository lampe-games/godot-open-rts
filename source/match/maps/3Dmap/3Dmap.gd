extends "res://source/match/Map.gd"

@onready var terrain :Terrain3D = find_child("Terrain3D") 

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
		var p_viewport_camera = get_viewport().get_camera_3d()
		var camera_pos: Vector3 = p_viewport_camera.project_ray_origin(event.position)
		var camera_dir: Vector3 = p_viewport_camera.project_ray_normal(event.position)
		var target_point = terrain.get_intersection(camera_pos,camera_dir)
		MatchSignals.terrain_targeted.emit(target_point)

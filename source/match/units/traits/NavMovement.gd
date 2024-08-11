extends Node3D

@onready var _Match = find_parent("Match")
@onready var _NavHandler = _Match.find_child("NavHandler")
@onready var _Unit = get_parent()

var target = Vector3()
var path = []
var path_index = 0
var path_visualizer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _exit_tree():
	if path_visualizer != null:
		path_visualizer.destroy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_Unit.velocity = _calculate_velocity(delta)
	_Unit.move_and_slide()

func _calculate_velocity(delta):
	var dir = Vector3()
	if not path:
		if _Unit.global_position.distance_to(target) > 0.5:
			path = _NavHandler.find_path(_Unit.global_position, target, null)
			path_index = 0
			if path_visualizer != null:
				path_visualizer.destroy()
				path_visualizer = null
			path_visualizer = _NavHandler.create_path_visualizer(path)
		else:
			return dir

	if path:
		if _Unit.global_position.distance_to(path[path_index]) < 0.2:
			path_index += 1
			if path_index >= path.size():
				path = null
				return Vector3()
		dir = ((path[path_index]+Vector3(0,0.1,0)) - _Unit.global_position).normalized()
	return dir * _Unit.movement_speed * delta
	#return 0.1*dir*_Unit.movement_speed + 0.9 * _Unit.velocity

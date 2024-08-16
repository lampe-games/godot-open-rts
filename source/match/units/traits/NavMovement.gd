extends Node3D

signal movement_finished
signal passive_movement_started
signal passive_movement_finished

@onready var _Match = find_parent("Match")
@onready var _NavHandler = _Match.find_child("NavHandler")
@onready var _Unit = get_parent()
@onready var _Terrain = _Match.find_child("Terrain3D")

@export var altitude = 2.0
@export var climb_angle = PI * 0.125
@export var min_target_distance = 2
@export var waypoint_reach = 0.1

var target = Vector3()
var path = []
var path_index = 0
var path_visualizer = null
var domain = Constants.Match.Navigation.Domain.TERRAIN

var _moving = false
var piloted = false
var radius = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _exit_tree():
	if path_visualizer != null:
		path_visualizer.destroy()

func move(movement_target: Vector3):
	target = movement_target
	_moving = true

func stop():
	target = _Unit.global_position
	path = null
	_moving = false

func _physics_process(delta):
	if piloted:
		return
	var _dir = Vector3()
	if _moving:
		_dir = _calculate_path_dir()
	
	if domain == Constants.Match.Navigation.Domain.AIR:
		_dir.y = _calculate_hold_altitude_dir().y
		
	_Unit.velocity = _dir.normalized() * _Unit.movement_speed * delta
	_Unit.move_and_slide()

func _calculate_path_dir():
	var dir = Vector3()
	if not path:
		if _Unit.global_position_yless.distance_to(target * Vector3(1,0,1)) > min_target_distance:
			path = _NavHandler.find_path_with_max_climb_angle(
				_Unit.global_position, target, null, climb_angle
			)
			path_index = 0
			if path_visualizer != null:
				path_visualizer.destroy()
				path_visualizer = null
			path_visualizer = _NavHandler.create_path_visualizer(path)
			_moving = true
		elif _moving:
			_moving = false
			movement_finished.emit()
			return dir
		else:
			return dir

	if path:
		if path_index < clamp(path.size(),0,10):
			dir = ((path[path_index]+Vector3(0,0.1,0)) - _Unit.global_position).normalized()
		else:
			path = null
			return Vector3()
		
		if _Unit.global_position_yless.distance_to(path[path_index]*Vector3(1,0,1)) < waypoint_reach:
			path_index += 1

		
	return dir
	#return 0.1*dir*_Unit.movement_speed + 0.9 * _Unit.velocity

func _calculate_hold_altitude_dir():
	var t_height = _Terrain.storage.get_height(_Unit.global_position)
	var u_height = _Unit.global_position.y
	var power = clampf((t_height+altitude)-u_height, -1.0, 1.0)
	if abs(power) <= 0.1:
		return Vector3() 
	return Vector3.UP * power

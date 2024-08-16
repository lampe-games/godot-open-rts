extends Node3D

var piloted = false

@onready var _match = find_parent("Match")
@onready var _unit = get_parent()
@onready var _UI_pos = find_child("PosValue")
@onready var _UI_velocity = find_child("VelocityValue")

var domain = Constants.Match.Navigation.Domain.TERRAIN
var radius = 0.5

var target = Vector3()

func move(movement_target: Vector3):
	target = movement_target

func stop():
	target = _unit.global_position

func _physics_process(delta):
	var _interim_speed = _unit.movement_speed * delta
	if not piloted:
		var next_path_position: Vector3 = Vector3()#get_next_path_position()
		var current_agent_position: Vector3 = _unit.global_position
		var new_velocity: Vector3 = (
			(next_path_position - current_agent_position).normalized() * _interim_speed
		)
		_unit.set_velocity(new_velocity)
	else:
		var xz_input = Input.get_vector("move_map_left", "move_map_right", "move_map_up", "move_map_down")
		var y_input = Input.get_axis("move_lower", "move_higher")
		var dir = Vector3(xz_input.x, y_input, xz_input.y).rotated(Vector3.UP, _unit.rotation.y)
		if Input.is_action_pressed("shift_selecting"):
			_unit.velocity = dir * _interim_speed * 100
		else:
			_unit.velocity = dir * _interim_speed
		_UI_pos.text = str(_unit.global_position)
		_UI_velocity.text = str(_unit.velocity)
	_unit.move_and_slide()

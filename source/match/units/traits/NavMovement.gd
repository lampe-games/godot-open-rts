extends Node3D

@onready var _Match = find_parent("Match")
@onready var _NavHandler = _Match.find_child("NavHandler")
@onready var _Unit = get_parent()

var target = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_calculate_velocity(delta)

func _calculate_velocity(delta):
	var path = _NavHandler.find_path(_Unit.global_position, target, null)
	var dir
	if not path:
		dir = Vector3()
	else:
		dir = (_Unit.global_position - path[0]).normalized()
	_Unit.velocity = 0.1*dir*_Unit.movement_speed + 0.9 * _Unit.velocity

extends Area3D

var radius = null:
	set = _ignore,
	get = _get_radius


func _ignore(_value):
	pass


func _get_radius():
	return find_child("MovementObstacle").radius

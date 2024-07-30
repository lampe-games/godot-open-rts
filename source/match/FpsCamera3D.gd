extends Camera3D

@export var mouse_sensitivity = 0.0015
@export var reference_plane_for_rotation = Plane(Vector3.UP, 0.0)

@onready var _unit = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if current and event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		_unit.rotation.y -= event.relative.x * mouse_sensitivity

func get_ray_intersection(mouse_pos):
	return get_ray_intersection_with_plane(mouse_pos, reference_plane_for_rotation)

func get_ray_intersection_with_plane(mouse_pos, plane):
	return plane.intersects_ray(project_ray_origin(mouse_pos), project_ray_normal(mouse_pos))

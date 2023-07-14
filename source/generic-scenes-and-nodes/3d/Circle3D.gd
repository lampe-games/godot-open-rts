@tool
extends Node3D

@export_range(0.001, 50.0) var radius = 1.0:
	set = _set_radius
@export_range(0.001, 50.0) var width = 10.0:
	set = _set_width
@export var color = Color.WHITE:
	set = _set_color
@export var render_priority: int = 0:  # TODO: report Godot bug here when no type hint present
	set = _set_render_priority

var _plane = null


func _ready():
	_plane = MeshInstance3D.new()
	_plane.mesh = PlaneMesh.new()
	_plane.material_override = ShaderMaterial.new()
	_plane.material_override.shader = preload("res://source/shaders/3d/circle.gdshader")
	_recalculate_plane_parameters()
	add_child(_plane)


func _set_radius(a_radius):
	radius = a_radius
	_recalculate_plane_parameters()


func _set_width(a_width):
	width = a_width
	_recalculate_plane_parameters()


func _set_color(a_color):
	color = a_color
	_recalculate_plane_parameters()


func _set_render_priority(a_render_priority):
	render_priority = a_render_priority
	_recalculate_plane_parameters()


func _recalculate_plane_parameters():
	if _plane == null:
		return
	_plane.mesh.size = Vector2(radius * 2.0, radius * 2.0)
	_plane.material_override.render_priority = render_priority
	_plane.material_override.set_shader_parameter("color", color)
	_plane.material_override.set_shader_parameter("width_pixels", width)
	_plane.material_override.set_shader_parameter("edge_width_pixels", 2.0)

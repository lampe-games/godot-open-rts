extends "res://source/match/units/Unit.gd"

# TODO: move to read-only properties
const SIGHT_RANGE = 10.0

var color = null:
	set(a_color):
		var material = StandardMaterial3D.new()
		material.albedo_color = a_color
		find_child("MeshInstance3D2").material_override = material

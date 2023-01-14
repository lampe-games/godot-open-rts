extends "res://source/match/units/Unit.gd"

const SIGHT_RANGE = 10.0

var color = null:
	set(a_color):
		var material = StandardMaterial3D.new()
		material.albedo_color = a_color
		find_child("MeshInstance3D").material_override = material

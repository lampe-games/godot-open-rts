extends Area3D

var color:
	set(a_color):
		var material = StandardMaterial3D.new()
		material.albedo_color = a_color
		find_child("MeshInstance3D2").material_override = material

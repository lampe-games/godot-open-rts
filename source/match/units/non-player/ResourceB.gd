# TODO: deduplicate (see ResourceA)
extends Area3D


func _ready():
	_setup_mesh_colors()


func _setup_mesh_colors():
	var material = StandardMaterial3D.new()
	material.albedo_color = Constants.Match.Resources.B.COLOR
	for child in get_children():
		if child.name.begins_with("Mesh"):
			child.material_override = material

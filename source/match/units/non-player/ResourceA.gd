extends Area3D

const MATERIAL_COLOR_TO_REPLACE = Color(0.4687, 0.944, 0.7938)

@export var resource_a = 300  # TODO: default from constants


func _ready():
	_setup_mesh_colors()


func _setup_mesh_colors():
	# TODO: use path from constants and preload
	var material = StandardMaterial3D.new()
	material.albedo_color = Constants.Match.Resources.A.COLOR
	for child in find_children("*"):
		if not "mesh" in child:
			continue
		for surface_id in range(child.mesh.get_surface_count()):
			var surface_material = child.mesh.get("surface_{0}/material".format([surface_id]))
			# TODO: create utility function
			if (
				surface_material != null
				and abs(surface_material.albedo_color.r - MATERIAL_COLOR_TO_REPLACE.r) < 0.1
				and abs(surface_material.albedo_color.g - MATERIAL_COLOR_TO_REPLACE.g) < 0.1
				and abs(surface_material.albedo_color.b - MATERIAL_COLOR_TO_REPLACE.b) < 0.1
			):
				child.set("surface_material_override/{0}".format([surface_id]), material)

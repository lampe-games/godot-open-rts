extends "res://source/match/units/non-player/ResourceUnit.gd"

const MATERIAL_ALBEDO_TO_REPLACE = Color(0.4687, 0.944, 0.7938)
const MATERIAL_ALBEDO_TO_REPLACE_EPSILON = 0.05

@export var resource_a = 300:
	set(value):
		resource_a = max(0, value)
		if resource_a == 0:
			queue_free()

var color = Constants.Match.Resources.A.COLOR:
	set(_value):
		pass


func _ready():
	_setup_mesh_colors()


func _setup_mesh_colors():
	# gdlint: ignore = function-preload-variable-name
	var material = preload(Constants.Match.Resources.A.MATERIAL_PATH)
	Utils.Match.traverse_node_tree_and_replace_materials_matching_albedo(
		self, MATERIAL_ALBEDO_TO_REPLACE, MATERIAL_ALBEDO_TO_REPLACE_EPSILON, material
	)

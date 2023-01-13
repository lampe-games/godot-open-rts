extends NavigationObstacle3D

@export_flags_3d_navigation var navigation_layers = int(Constants.Match.NavigationLayers.TERRAIN)
@export var agent_height_offset = 0.0

@onready var _match = find_parent("Match")
@onready var _unit = get_parent()


func _ready():
	await get_tree().process_frame  # wait for navigation to be operational
	set_navigation_map(_match.navigation.get_navigation_map_rid_by_layer(navigation_layers))
	_align_unit_position_to_navigation()


func _align_unit_position_to_navigation():
	# TODO: use new API once available
	_unit.global_transform.origin = (
		NavigationServer3D.map_get_closest_point(
			get_navigation_map(), get_parent().global_transform.origin
		)
		- Vector3(0, agent_height_offset, 0)
	)

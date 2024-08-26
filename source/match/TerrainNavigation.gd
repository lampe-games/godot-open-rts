extends Node3D

const DOMAIN = Constants.Match.Navigation.Domain.TERRAIN

var _earliest_frame_to_perform_next_rebake = null
var _is_baking = false
var _map_geometry = NavigationMeshSourceGeometryData3D.new()

@onready var navigation_map_rid = get_world_3d().navigation_map

@onready var _navigation_region = find_child("NavigationRegion3D")


func _ready():
	assert(_safety_checks())
	NavigationServer3D.map_set_cell_size(
		navigation_map_rid, Constants.Match.Terrain.Navmesh.CELL_SIZE
	)
	NavigationServer3D.map_set_cell_height(
		navigation_map_rid, Constants.Match.Terrain.Navmesh.CELL_HEIGHT
	)
	NavigationServer3D.map_force_update(navigation_map_rid)
	MatchSignals.schedule_navigation_rebake.connect(_on_schedule_navigation_rebake)


func _process(_delta):
	if (
		not _is_baking
		and _earliest_frame_to_perform_next_rebake != null
		and get_tree().get_frame() >= _earliest_frame_to_perform_next_rebake
	):
		_is_baking = true
		_earliest_frame_to_perform_next_rebake = null
		_rebake()


func bake(map):
	assert(
		_navigation_region.navigation_mesh.get_polygon_count() == 0,
		"bake() should be called exactly once - during runtime"
	)
	# setting custom AABB for baking so that height of dynamic AABB is always the same
	# - without such setting, re-baking may yield different results depending on geometry height
	_navigation_region.navigation_mesh.filter_baking_aabb = AABB(
		Vector3.ZERO, Vector3(map.size.x, 5.0, map.size.y)
	)
	NavigationServer3D.parse_source_geometry_data(
		_navigation_region.navigation_mesh, _map_geometry, get_tree().root
	)
	for node in get_tree().get_nodes_in_group("terrain_navigation_input"):
		node.remove_from_group("terrain_navigation_input")
	NavigationServer3D.bake_from_source_geometry_data(
		_navigation_region.navigation_mesh, _map_geometry
	)
	_sync_navmesh_changes()


func _rebake():
	# parse geometry other than map itself
	var full_geometry = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(
		_navigation_region.navigation_mesh, full_geometry, get_tree().root
	)
	# add pre-parsed map geometry
	full_geometry.merge(_map_geometry)

	NavigationServer3D.bake_from_source_geometry_data_async(
		_navigation_region.navigation_mesh, full_geometry, _on_bake_finished
	)


# TODO: remove whenever Godot fixes that on its side
func _sync_navmesh_changes():
	"""this function forces synchronization between server-level primitives and nodes"""
	_navigation_region.navigation_mesh = _navigation_region.navigation_mesh


func _safety_checks():
	assert(
		is_equal_approx(
			_navigation_region.navigation_mesh.agent_radius,
			Constants.Match.Terrain.Navmesh.MAX_AGENT_RADIUS
		),
		"Navmesh 'agent_radius' must match established constant"
	)
	assert(
		is_equal_approx(
			_navigation_region.navigation_mesh.cell_size, Constants.Match.Terrain.Navmesh.CELL_SIZE
		),
		"Navmesh 'cell_size' must match established constant"
	)
	assert(
		is_equal_approx(
			_navigation_region.navigation_mesh.cell_height,
			Constants.Match.Terrain.Navmesh.CELL_HEIGHT
		),
		"Navmesh 'cell_height' must match established constant"
	)
	return true


func _on_schedule_navigation_rebake(domain):
	if domain != DOMAIN or not is_inside_tree() or not FeatureFlags.allow_navigation_rebaking:
		return
	if _earliest_frame_to_perform_next_rebake == null:
		_earliest_frame_to_perform_next_rebake = get_tree().get_frame() + 1


func _on_bake_finished():
	_sync_navmesh_changes()
	_is_baking = false

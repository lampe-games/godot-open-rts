extends Node3D

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


func rebake(on_thread:bool):
	_navigation_region.bake_navigation_mesh(on_thread)


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

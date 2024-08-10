

static func compute_terrain_extent(map):
	var terrain = map.find_child("Terrain3D")
	var m = terrain.bake_mesh(4, Terrain3DStorage.HEIGHT_FILTER_NEAREST)
	var box = m.get_aabb()  # FIXME: Investigate if this leaks.
	var min_x = min(box.position.x, box.end.x)
	var max_x = max(box.position.x, box.end.x)
	var min_y = min(box.position.y, box.end.y)
	var max_y = max(box.position.y, box.end.y)
	var min_z = min(box.position.z, box.end.z)
	var max_z = max(box.position.z, box.end.z)
	return [min_x, max_x, min_y, max_y, min_z, max_z]

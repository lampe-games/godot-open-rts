extends Node3D

@export var debugNavMesh = false

const MapCollisionUtils = preload("res://source/match/utils/MapCollisionUtils.gd")
const _debugmarker = preload("res://source/DebugMarker3D.tscn")

var _proplayers = {}
@onready var _map = find_parent("Match").find_child("Map")
@onready var _gamematch = find_parent("Match")
@onready var HeightMapNavMeshClass = load("res://source/match/utils/HeightMapNavMesh.gd")
@onready var NavHandlerPathVisualizerClass = load("res://source/match/handlers/NavHandlerPathVisualizer.gd")
var _hmnavmesh = null
var _map_scanned = false

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if not _map_scanned:
		_map_scanned = true
		var extents = MapCollisionUtils.compute_terrain_extent(_map)
		var terrain = _map.find_child("Terrain3D")
		var world_3d = get_world_3d()
		_hmnavmesh = HeightMapNavMeshClass.new()
		var _spawn_marker_callback = _spawn_marker
		if not debugNavMesh:
			_spawn_marker_callback = null
		_hmnavmesh.initialize_by_scanning_ex(
			world_3d,
			extents[0], extents[1], extents[2], extents[3], extents[4], extents[5],
			2, terrain, _spawn_marker_callback
		)

func _spawn_marker(pos):
	var dm = _debugmarker.instantiate()
	_gamematch.find_child("Units").add_child(dm)
	dm.global_position = pos

func find_path(src, dst, costFunc):
	if not _map_scanned:
		return []
	var result = _hmnavmesh.find_path(costFunc, src, dst)
	return result

func find_path_with_max_climb_angle(
		src, dst, costFunc, angle):
	if not _map_scanned:
		return []
	var result = _hmnavmesh.find_path_with_max_climb_angle(
		costFunc, src, dst, angle)
	return result

func enable_proplayer_float(layer_name):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	var layer = _proplayers[layer_name]
	if layer.has("float") and layer["float"] == true:
		return
	layer["float"] = true
	if layer.has("data"):
		layer.erase("data")

func query_proplayer_max_value(layer_name, world_pos, world_radius):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	return _query_proplayer_do(layer_name, world_pos, world_radius, false)

func _query_proplayer_do(layer_name, world_pos, world_radius,
		is_get_min_value):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	var layer = _proplayers[layer_name]
	var isfloat = false
	var result = 0
	if (_proplayers.has("float") and
			_proplayers["float"] == true):
		isfloat = true
		result = 0.0
	if not _map_scanned:
		return result
	var query_value = func(idx):
		if is_get_min_value:
			result = min(result, layer["data"][idx])
		else:
			result = max(result, layer["data"][idx])
	_do_circular_on_proplayer(
		layer, query_value, world_pos, world_radius
	)
	return result

func query_proplayer_min_value(layer_name, world_pos, world_radius):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	return _query_proplayer_do(layer_name, world_pos, world_radius, true)

func query_proplayer_rectangle_max_value(layer_name,
		rectangle_center_world_pos, rectangle_size):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		if (_proplayers.has("float") and
				_proplayers["float"] == true):
			return 0.0
		return 0

	var positions = _proplayer_rectangle_to_search_positions(
		rectangle_center_world_pos, rectangle_size
	)
	var max_so_far = -2147483648
	for pos in positions:
		max_so_far = max(max_so_far,
			query_proplayer_max_value(layer_name,
				pos, 0))
	return max_so_far

func query_proplayer_rectangle_min_value(layer_name,
		rectangle_center_world_pos, rectangle_size):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		if (_proplayers.has("float") and
				_proplayers["float"] == true):
			return 0.0
		return 0

	var positions = _proplayer_rectangle_to_search_positions(
		rectangle_center_world_pos, rectangle_size
	)
	var min_so_far = 2147483647
	for pos in positions:
		min_so_far = min(min_so_far,
			query_proplayer_min_value(layer_name,
				pos, 0))
	return min_so_far

func add_to_proplayer(layer_name, value, world_pos, world_radius):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		OS.alert("add_to_proplayer() cannot be called before " +
			"first _physics_process() has initialized the " +
			"path finding map")
		return
	var layer = _proplayers[layer_name]
	if not layer.has("data"):
		var data
		if (_proplayers.has("float") and
				_proplayers["float"] == true):
			data = PackedFloat64Array()
		else:
			data = PackedInt32Array()
		var i = 0
		while (i < _hmnavmesh.get_field_x_width() *
				_hmnavmesh.get_field_z_width()):
			data.append(0)
			i += 1
		layer["data"] = data
	var add_value = func(idx):
		layer["data"][idx] += value
	_do_circular_on_proplayer(
		layer, add_value, world_pos, world_radius
	)

func _do_circular_on_proplayer(
		layer, do_callback, world_pos, world_radius):
	if not layer.has("data"):
		return

	# In all cases, set this to the closest grid point:
	var center_offset = _hmnavmesh.pos_to_offset(
		Vector3(world_pos.x, 0, world_pos.z)
	)
	assert(typeof(center_offset) == TYPE_VECTOR2I)
	do_callback.call(
		center_offset.x + center_offset.y *
		_hmnavmesh.get_field_x_width()
	)
	if world_radius == 0:
		# If we have no radius, don't touch anything further.
		return
	# Otherwise, set it to all grid points within the radius:
	var slice_range = _hmnavmesh.get_grid_slice_width()
	var search_range_units = ceil(
		(world_radius / slice_range) + 0.5
	)
	var xi = center_offset.x - slice_range
	while xi <= center_offset.x + slice_range:
		var yi = center_offset.y - slice_range
		while yi <= center_offset.y + slice_range:
			if (xi < 0 or xi >= _hmnavmesh.get_field_x_width() or
					yi < 0 or yi >= _hmnavmesh.get_field_z_width()):
				yi += 1
				continue
			if xi == center_offset.x and yi == center_offset.y:
				# We already handled that above.
				yi += 1
				continue
			var found_world_pos = _hmnavmesh.offset_to_pos(
				Vector2i(xi, yi)
			)
			var dist = Vector2(
				abs(found_world_pos.x - world_pos.x),
				abs(found_world_pos.z - world_pos.z)
			)
			if dist <= world_radius:
				do_callback.call(
					xi + yi *
					_hmnavmesh.get_field_x_width()
				)
			yi += 1
		xi += 1

func add_to_proplayer_rectangle(layer_name, value,
		rectangle_center_world_pos, rectangle_size):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		OS.alert("add_to_proplayer_rectangle() cannot be called before " +
			"first _physics_process() has initialized the " +
			"path finding map")
		return
	if typeof(rectangle_center_world_pos) != TYPE_VECTOR3:
		OS.alert("incorrect type for rectangle_center_world_pos")
		return
	var positions = _proplayer_rectangle_to_search_positions(
		rectangle_center_world_pos, rectangle_size
	)
	for pos in positions:
		add_to_proplayer(layer_name, value,
			pos, 0)

func _proplayer_rectangle_to_search_positions(
		rectangle_center_world_pos, rectangle_size
		):
	if (typeof(rectangle_size) != TYPE_VECTOR2 and
			typeof(rectangle_size) != TYPE_VECTOR2I):
		OS.alert("incorrect type for rectangle_size")
		return
	var min_x = (float(rectangle_center_world_pos.x) -
		float(rectangle_size.x) / 2)
	var max_x = (float(rectangle_center_world_pos.x) +
		float(rectangle_size.x) / 2)
	var min_z = (float(rectangle_center_world_pos.z) -
		float(rectangle_size.y) / 2)
	var max_z = (float(rectangle_center_world_pos.z) +
		float(rectangle_size.y) / 2)
	var min_offset = _hmnavmesh.pos_to_offset(
		Vector3(min_x, 0, min_z)
	)
	var max_offset = _hmnavmesh.pos_to_offset(
		Vector3(max_x, 0, max_z)
	)
	var world_positions = []
	var xi = min_offset.x
	while xi <= max_offset.x:
		var yi = min_offset.y
		while yi < max_offset.y:
			var world_pos = _hmnavmesh.offset_to_pos(
				Vector2i(xi, yi)
			)
			world_positions.append(world_pos)
			yi += 1
		xi += 1
	return world_positions

func subtract_from_proplayer(layer_name, value, world_pos, world_radius):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		OS.alert("subtract_from_proplayer() cannot be called before " +
			"first _physics_process() has initialized the " +
			"path finding map")
		return
	return add_to_proplayer(
		layer_name, -value, world_pos, world_radius
	)

func subtract_from_proplayer_rectangle(layer_name, value,
		rectangle_center_world_pos, rectangle_size):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		OS.alert("subtract_from_proplayer_rectangle() cannot be called before " +
			"first _physics_process() has initialized the " +
			"path finding map")
		return
	return add_to_proplayer_rectangle(
		layer_name, value, rectangle_center_world_pos, rectangle_size
	)

func set_on_proplayer(layer_name, value, world_pos, world_radius):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		OS.alert("set_on_proplayer() cannot be called before " +
			"first _physics_process() has initialized the " +
			"path finding map")
		return
	var layer = _proplayers[layer_name]
	var set_value = func(idx):
		layer["data"][idx] = value
	_do_circular_on_proplayer(
		layer, set_value, world_pos, world_radius
	)

func set_on_proplayer_rectangle(layer_name, value,
		rectangle_center_world_pos, rectangle_size):
	if not _proplayers.has(layer_name):
		_proplayers[layer_name] = {
			"name": layer_name
		}
	if not _map_scanned:
		OS.alert("set_on_proplayer_rectangle() cannot be called before " +
			"first _physics_process() has initialized the " +
			"path finding map")
		return
	
	var positions = _proplayer_rectangle_to_search_positions(
		rectangle_center_world_pos, rectangle_size
	)
	for pos in positions:
		set_on_proplayer(layer_name, value,
			pos, 0)

func create_path_visualizer(path):
	var vis = NavHandlerPathVisualizerClass.new()
	vis.set_nav_mesh(_hmnavmesh)
	vis.set_match(_gamematch)
	vis.set_path(path)
	return vis

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

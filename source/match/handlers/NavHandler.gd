extends Node3D

@export var debugNavMesh = false

const MapCollisionUtils = preload("res://source/match/utils/MapCollisionUtils.gd")
const _debugmarker = preload("res://source/DebugMarker3D.tscn")

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

func create_path_visualizer(path):
	var vis = NavHandlerPathVisualizerClass.new()
	vis.set_nav_mesh(_hmnavmesh)
	vis.set_match(_gamematch)
	vis.set_path(path)
	return vis

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

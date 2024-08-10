extends Node3D
const MapCollisionUtils = preload("res://source/match/utils/MapCollisionUtils.gd")
@onready var _map = find_parent("Match").find_child("Map")
@onready var _gamematch = find_parent("Match")
var _hmnavmesh = null
const _debugmarker = preload("res://source/DebugMarker3D.tscn")
@onready var HeightMapNavMeshClass = load("res://source/match/utils/HeightMapNavMesh.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var extents = MapCollisionUtils.compute_terrain_extent(_map)
	var dm1 = _debugmarker.instantiate()
	_gamematch.add_child(dm1)
	#_gamematch.global_position = Vector3(0, 1, 0)
	var terrain = _map.find_child("Terrain3D")
	print(terrain.storage.get_height(Vector3(135,0,0)))
	print(extents)
	var world_3d = get_world_3d()
	_hmnavmesh = HeightMapNavMeshClass.new()
	_hmnavmesh.initialize_by_scanning(
		world_3d,
		extents[0], extents[1], extents[2], extents[3], extents[4], extents[5],
		0.6
	)
	pass # Replace with function body.

func find_path(src, dst, costFunc):
	_hmnavmesh.find_path(costFunc, src, dst)

func find_path_with_max_climb_angle(costFunc,
		src, dst, angle):
	_hmnavmesh.find_path_with_max_climb_angle(costFunc, src, dst, angle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Node3D
const MapCollisionUtils = preload("res://source/match/utils/MapCollisionUtils.gd")
@onready var _map = find_parent("Match").find_child("Map")
@onready var _gamematch = find_parent("Match")
const _debugmarker = preload("res://source/DebugMarker3D.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var extents = MapCollisionUtils.compute_terrain_extent(_map)
	var dm1 = _debugmarker.instantiate()
	_gamematch.add_child(dm1)
	#_gamematch.global_position = Vector3(0, 1, 0)
	var terrain = _map.find_child("Terrain3D")
	print(terrain.storage.get_height(Vector3(135,0,0)))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

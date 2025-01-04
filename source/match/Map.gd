@tool
extends Node3D

# TODO: add editor-only 2nd pass shader to 'Terrain' mesh highlighting map boundries

const EXTRA_MARGIN = 2

@export var size = Vector2(50, 50):
	set(a_size):
		size = a_size
		find_child("Terrain").mesh.size = size + Vector2(EXTRA_MARGIN, EXTRA_MARGIN) * 2
		find_child("Terrain").mesh.center_offset = Vector3(size.x, 0.0, size.y) / 2.0


func get_topdown_polygon_2d():
	return [Vector2(0, 0), Vector2(size.x, 0), size, Vector2(0, size.y)]

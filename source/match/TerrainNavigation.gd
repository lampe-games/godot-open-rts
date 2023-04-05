extends Node3D

@onready var navigation_map_rid = get_world_3d().navigation_map

@onready var _navigation_region = find_child("NavigationRegion3D")


func rebake():
	_navigation_region.bake_navigation_mesh(false)

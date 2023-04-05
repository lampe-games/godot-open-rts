extends Node3D

# air needs to be put on separate map so that air agents do not collide with terrain ones:
@onready var navigation_map_rid = NavigationServer3D.map_create()

@onready var _navigation_region = find_child("NavigationRegion3D")
@onready var _reference_mesh = find_child("ReferenceMesh")


func _ready():
	NavigationServer3D.region_set_map(_navigation_region.get_region_rid(), navigation_map_rid)
	NavigationServer3D.map_force_update(navigation_map_rid)
	NavigationServer3D.map_set_active(navigation_map_rid, true)
	_reference_mesh.global_transform.origin.y = Constants.Match.Air.Y


func rebake(map):
	find_child("ReferenceMesh").mesh = map.find_child("Terrain").mesh
	_navigation_region.bake_navigation_mesh(false)

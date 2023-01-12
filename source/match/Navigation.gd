extends Node3D

# air needs to be put on separate map so that air agents do not collide with terrain ones:
@onready var air = ConcreteNavigation.new(NavigationServer3D.map_create())
@onready var terrain = ConcreteNavigation.new(get_world_3d().navigation_map)

@onready var _air_region = find_child("Air").find_child("NavigationRegion3D")


class ConcreteNavigation:
	var navigation_map_rid = null

	func _init(map_rid):
		navigation_map_rid = map_rid


func _ready():
	_setup_air_navigation_map()


func get_navigation_map_rid_by_layer(layer):
	return {
		Constants.Match.NavigationLayers.AIR: air.navigation_map_rid,
		Constants.Match.NavigationLayers.TERRAIN: terrain.navigation_map_rid,
	}[layer]


func _setup_air_navigation_map():
	NavigationServer3D.region_set_map(_air_region.get_region_rid(), air.navigation_map_rid)
	NavigationServer3D.map_force_update(air.navigation_map_rid)
	NavigationServer3D.map_set_active(air.navigation_map_rid, true)

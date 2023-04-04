extends Node3D

const NAVIGATION_FIXING_TIMER_INTERVAL_S = 0.1

var _dummy_agent_rids = {
	Constants.Match.Navigation.Domain.AIR: null,
	Constants.Match.Navigation.Domain.TERRAIN: null,
}

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
	_setup_navigation_fixing_timer()


func get_navigation_map_rid_by_domain(domain):
	return {
		Constants.Match.Navigation.Domain.AIR: air.navigation_map_rid,
		Constants.Match.Navigation.Domain.TERRAIN: terrain.navigation_map_rid,
	}[domain]


func rebake(map):
	# TODO: rebake air with changed air navreg transform
	find_child("ReferenceMesh").mesh = map.find_child("Terrain").mesh
	_air_region.bake_navigation_mesh(false)
	find_child("Terrain").find_child("NavigationRegion3D").bake_navigation_mesh(false)


func _setup_air_navigation_map():
	NavigationServer3D.region_set_map(_air_region.get_region_rid(), air.navigation_map_rid)
	NavigationServer3D.map_force_update(air.navigation_map_rid)
	NavigationServer3D.map_set_active(air.navigation_map_rid, true)


func _setup_navigation_fixing_timer():
	var timer = Timer.new()
	timer.timeout.connect(_fix_navigation)
	add_child(timer)
	timer.start(NAVIGATION_FIXING_TIMER_INTERVAL_S)


func _fix_navigation():
	"""workarounds Godot bug #72202"""
	for domain in [
		Constants.Match.Navigation.Domain.AIR, Constants.Match.Navigation.Domain.TERRAIN
	]:
		if _dummy_agent_rids[domain] == null:
			_dummy_agent_rids[domain] = NavigationServer3D.agent_create()
			NavigationServer3D.agent_set_position(_dummy_agent_rids[domain], Vector3(-99, 0, -99))
			NavigationServer3D.agent_set_map(
				_dummy_agent_rids[domain], get_navigation_map_rid_by_domain(domain)
			)
		else:
			NavigationServer3D.free_rid(_dummy_agent_rids[domain])
			_dummy_agent_rids[domain] = null

extends Node3D

const NAVIGATION_FIXING_TIMER_INTERVAL_S = 0.1

var _dummy_agent_rids = {
	Constants.Match.Navigation.Domain.AIR: null,
	Constants.Match.Navigation.Domain.TERRAIN: null,
}

@onready var air = find_child("Air")
@onready var terrain = find_child("Terrain")


func _ready():
	_setup_navigation_fixing_timer()


func get_navigation_map_rid_by_domain(domain):
	return {
		Constants.Match.Navigation.Domain.AIR: air.navigation_map_rid,
		Constants.Match.Navigation.Domain.TERRAIN: terrain.navigation_map_rid,
	}[domain]


func rebake(map):
	air.rebake(map)
	terrain.rebake()


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
